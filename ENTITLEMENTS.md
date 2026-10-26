# Capabilities under free-account (Personal Team) signing

**Status:** updated 2026-08-08. **Verified** by building for a real device and inspecting the
signed entitlements.

## ⚠️ Read this first: the App Group entitlement controls where SwiftData stores your data

**Do not disable `com.apple.security.application-groups`.** It is not just a widget setting.

`App.swift` uses `.modelContainer(for: NewBill.self)`, which builds a `ModelConfiguration` with
`groupContainer: .automatic`. That resolves like this:

| App Group entitlement | Where `default.store` lives |
|---|---|
| present | the **shared App Group container** (`.../Shared/AppGroup/<UUID>/Library/Application Support/`) |
| absent | the **app's own container** (`.../Data/Application/<UUID>/Library/Application Support/`) |

Removing the entitlement does not produce an error. SwiftData silently creates a brand-new empty
store in the app's own container and the app looks completely wiped. Worse, once no installed app
declares the group, **iOS garbage-collects the shared container and the old store is destroyed.**

This happened on 2026-08-08 and cost the on-device bill data. Forensics that identified it:

```
$ sqlite3 default.store "SELECT * FROM Z_PRIMARYKEY;"
1|NewBill|0|0          # Z_MAX = 0 -> this store never held a single row
$ sqlite3 default.store "SELECT COUNT(*) FROM ATRANSACTION;"
0                      # no history -> newly created, not emptied
```

Meanwhile `Library/Preferences/com.claytonwatkins.Billsly.plist` still carried its old July 2026
timestamp, proving the app container itself was never wiped — only the store had moved.

**App Groups is supported on a free Personal Team.** It provisions without complaint. There is no
reason to ever turn it off here.

## What is actually disabled, and why

### iCloud / CloudKit — disabled (cannot be provisioned free)

Verified failure on a free team:

> Cannot create a iOS App Development provisioning profile for "com.claytonwatkins.Billsly".
> Personal development teams, including "Clayton Watkins", do not support the iCloud capability.

This one is unavoidable without a paid membership. Note what it means for this app: SwiftData's
`.modelContainer(for:)` also defaults to `cloudKitDatabase: .automatic`, so with the iCloud
entitlement present the store was mirroring to CloudKit (the `Library/Caches/CloudKit/` directory
on the device confirmed active mirroring). Disabling iCloud **stops sync but does not move the
local store** — only the App Group entitlement does that.

### Push Notifications — disabled

Not tested against the free team; left off because it is unused. The app only schedules **local**
notifications (`UNUserNotificationCenter` in `SwiftUI/Services/BillService.swift` and
`HomeScreenView.swift`), which need no entitlement. There is no remote-push code anywhere: nothing
calls `registerForRemoteNotifications`, and there is no
`didRegisterForRemoteNotificationsWithDeviceToken` handler.

### App Groups — ENABLED, leave it alone

See the warning above.

## The other change: `StoreKit.framework` unlinked

`project.pbxproj` — removed `StoreKit.framework` from the target's **Frameworks build phase**
(Link Binary With Libraries) plus its orphaned `PBXBuildFile` entry.

This was the actual device-build blocker:

> Personal development teams do not support the In-App Purchase capability.

In-App Purchase has **no entitlement key on iOS** and was declared nowhere in this project — no
`SystemCapabilities` block, nothing in the entitlements file. Xcode's `GatherProvisioningInputs`
step infers the capability from `StoreKit.framework` being *explicitly linked*, then demands a
profile containing it. Because the inference is local to the target, it followed the app across
bundle identifiers.

**Unlinking is functionally a no-op.** `import StoreKit` still autolinks the framework. Verified on
the signed device binary:

```
$ otool -L ".../Expense and Budget Tracker.debug.dylib" | grep -i storekit
	/System/Library/Frameworks/StoreKit.framework/StoreKit
	/System/Library/Frameworks/_StoreKit_SwiftUI.framework/_StoreKit_SwiftUI
```

`StoreKit.framework` remains in the project navigator; it is just not in the link phase.
`IAPManager.swift` and `SettingsView.swift` are untouched. Real purchases still will not work on a
Personal Team — inherent to a free account. `Resources/Configuration.storekit` is already wired
into the scheme and simulates purchases with no Apple account.

## Unchanged, on purpose

- `DEVELOPMENT_TEAM = XR5S8WV6LB` — the lapsed membership did **not** create a new team. The
  existing team downgraded in place and keeps its ID; Xcode just labels it "(Personal Team)".
  Confirmed via the signing certificate's OU:
  ```bash
  security find-certificate -c "Apple Development: Clayton Watkins (X9M92YD6JA)" -p | openssl x509 -noout -subject -nameopt multiline
  # organizationalUnitName = XR5S8WV6LB
  ```
- `PRODUCT_BUNDLE_IDENTIFIER = com.claytonwatkins.Billsly` — unchanged. (It was briefly changed to
  `.dev` while chasing the IAP error; that was unnecessary and has been reverted. It was never
  installed on the device.)
- `BillslyWidgetsExtension.entitlements` — orphaned; the widget target no longer exists.
- `UIBackgroundModes: remote-notification` in `Resources/Info.plist` — an Info.plist key, not an
  entitlement, so it does not affect provisioning. Dead but harmless.

---

# Current verified state

```bash
xcodebuild -project "Billsly/Expense and Budget Tracker.xcodeproj" -scheme "Expense and Budget Tracker" -destination 'generic/platform=iOS' -configuration Debug build -allowProvisioningUpdates
# ** BUILD SUCCEEDED **
# Provisioning Profile: "iOS Team Provisioning Profile: com.claytonwatkins.Billsly"
```

Signed entitlements on the installed device build:

```
application-identifier              => XR5S8WV6LB.com.claytonwatkins.Billsly
com.apple.developer.team-identifier => XR5S8WV6LB
com.apple.security.application-groups => [ group.com.claytonwatkins.Billsly ]
get-task-allow                      => true
```

Free-team profiles expire after **7 days** — rebuild from Xcode to refresh. If profiles get stuck:

```bash
rm -rf ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles
```

**Quit and reopen Xcode after editing `project.pbxproj` on disk** — Xcode holds it in memory and
overwrites external edits. It did exactly that once during this work.

## Useful device forensics

Inspect what the app actually has on the device (works because dev builds carry `get-task-allow`):

```bash
# app's own container
xcrun devicectl device info files --device <UDID> --domain-type appDataContainer --domain-identifier com.claytonwatkins.Billsly

# shared App Group container - where SwiftData actually stores data
xcrun devicectl device info files --device <UDID> --domain-type appGroupDataContainer --domain-identifier group.com.claytonwatkins.Billsly

# pull the store and count rows
xcrun devicectl device copy from --device <UDID> --domain-type appGroupDataContainer \
  --domain-identifier group.com.claytonwatkins.Billsly \
  --source "Library/Application Support/default.store" --destination ./default.store
sqlite3 default.store "SELECT COUNT(*) FROM ZNEWBILL;"
```

---

# Re-enabling after rejoining the paid program

Team and bundle ID need no change — re-upgrading `XR5S8WV6LB` restores provisioning under the same
IDs. Each item is independent.

### iCloud / CloudKit

Uncomment `com.apple.developer.icloud-container-identifiers` and
`com.apple.developer.icloud-services` in the entitlements file, and confirm the container
`iCloud.com.ClaytonWatkins.Billsly` is enabled on the App ID at
<https://developer.apple.com/account/resources/identifiers>. Easiest path is **+ Capability** in
Xcode's Signing & Capabilities, then diff against the backup below — Xcode sometimes writes a
different container name.

Once restored, SwiftData resumes CloudKit mirroring and **any records still in the iCloud private
database sync back down.** CloudKit data is not deleted by app reinstalls.

### In-App Purchase

Target → **General** → **Frameworks, Libraries, and Embedded Content** → **+** →
`StoreKit.framework`. Xcode re-infers the capability.

### Push Notifications

Uncomment `aps-environment`. This restores the capability only — the remote-push code would still
need writing from scratch.

### App Groups / widget

Already enabled. Restoring the entitlement alone never brings the widget back: the `BillslyWidgets`
target no longer exists (removed in `409375d`, `53204da`). That needs a new Widget Extension
target, uncommenting `Billsly/BillslyWidgets/BillslyWidgets.swift`, re-wiring
`Billsly/BillslyWidgetsExtension.entitlements`, and restoring the writer side in
`SwiftUI/Model/Old Models/WidgetDataBills.swift`.

### Verify

```bash
codesign -d --entitlements - --xml "$(xcodebuild -project "Billsly/Expense and Budget Tracker.xcodeproj" -scheme "Expense and Budget Tracker" -showBuildSettings 2>/dev/null | awk -F' = ' '/ CODESIGNING_FOLDER_PATH/{print $2}')" | plutil -p -
```

---

## Original entitlements file (verbatim backup)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>development</string>
	<key>com.apple.developer.icloud-container-identifiers</key>
	<array>
		<string>iCloud.com.ClaytonWatkins.Billsly</string>
	</array>
	<key>com.apple.developer.icloud-services</key>
	<array>
		<string>CloudKit</string>
	</array>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.claytonwatkins.Billsly</string>
	</array>
</dict>
</plist>
```
