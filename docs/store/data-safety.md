# Data safety and app privacy answers

Draft answers based on the code at alpha 0.4.0. Two build variants exist: a local-only build (no Supabase variables) and a build with the optional Supabase project. Answer for the variant you publish; the answers below assume the Supabase build, the stricter case. Re-verify against the final build before submitting.

## Google Play: Data safety form

### Overview questions

| Question | Answer |
| --- | --- |
| Does the app collect or share user data? | Yes (account email and evening data, only if the user uses those features) |
| Is all collected data encrypted in transit? | Yes (HTTPS to the server). Note: the same-Wi-Fi room uses an unencrypted local WebSocket and is not sent to a server; it is not "collected" by the developer |
| Can users request data deletion? | Yes: in-app "Erase all my data" for everything stored on the device, account deletion by an administrator or on request, and evening deletion by the host. Provide the deletion URL or contact in the policy |
| Independent security review | No |
| Committed to the Play Families policy | No (not designed for children) |

### Data types

| Category | Data type | Collected | Shared | Purpose | Optional |
| --- | --- | --- | --- | --- | --- |
| Personal info | Email address | Yes | No | Account management, authentication | Yes (account is optional) |
| Personal info | Name (optional first name, guest names on evenings) | Yes | No | App functionality | Yes |
| Personal info | User IDs (account identifier) | Yes | No | Account management | Yes |
| App activity | Other user-generated content (evening details and answers) | Yes | No | App functionality | Yes |
| Photos and videos | Photos | No (kept on device, never sent to the developer) | No | - | - |
| Location | Any | No | No | - | - |
| Financial info | Any | No | No | - | - |
| Health and fitness | Any | No | No | - | - |
| Messages | Any | No (room messages are relayed, not stored) | No | - | - |
| App info and performance | Crash logs, diagnostics | No | No | - | - |
| Device or other IDs | Advertising ID or device ID | No | No | - | - |
| Web browsing, contacts, calendar, audio, files | Any | No | No | - | - |

Notes for the reviewer:
- Camera: used only to scan QR codes on device; no image is kept or transmitted. The camera is not a data type collected; mention it in the permissions justification.
- Service providers (Supabase) process data on the developer's behalf; Google's definitions treat this as not "sharing".
- If the published build has no Supabase variables, answer "No data collected" and "No data shared".

### Other declarations

- Ads: No ads.
- Permissions: INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE, and CAMERA (requested by the scanner library when a QR scan starts; verify the merged manifest of the release build).
- Target audience: general audience 13+, not designed for children.

## Apple: App Privacy ("nutrition labels")

| Question | Answer |
| --- | --- |
| Do you or third-party partners collect data from this app? | Yes, with the Supabase build; No for the local-only build |
| Tracking (linking data with third-party data for ads, or sharing with data brokers) | No. No App Tracking Transparency prompt is needed |

Data types collected (all "Data Linked to You", none used for tracking):

| Data type | Purpose | Notes |
| --- | --- | --- |
| Contact Info: Email Address | App Functionality (authentication) | Only if the user creates an account |
| Contact Info: Name | App Functionality | Optional first name and guest names on evenings |
| Identifiers: User ID | App Functionality | Account identifier |
| User Content: Other User Content | App Functionality | Published evenings and answers |

Not collected: location, contacts, health, financial, browsing history, search history, diagnostics, usage data, purchases, sensitive info, photos or videos (kept on device), audio.

Required Info.plist purposes already present:
- NSCameraUsageDescription: scan QR codes to join a game or receive a pack.
- NSLocalNetworkUsageDescription: find and join open games on the user's Wi-Fi. Both strings are localized in the seven app languages through `InfoPlist.strings` (English is the default value in Info.plist).

Other Apple items:
- Privacy policy URL: required, use the published privacy policy.
- Age rating: no objectionable content; user-generated content exists only as player-entered text shared with invited guests (answer the questionnaire accordingly, "no unrestricted web access").
- Account deletion: if accounts can be created in the app, Apple requires an in-app way to initiate deletion. Settings, under History, offers "Erase all my data": after a confirmation dialog it wipes the local database (games, library, photos, dice, preferences) and returns to the home screen. Server-side account deletion is still an administrator flow, so a self-service account deletion call remains to be added before the iOS release if accounts stay enabled.
- Export compliance: the app uses standard encryption (HTTPS) plus cryptographic primitives for sealed boxes and hashing. Declare it and answer the encryption questions; most apps in this case qualify for the exemption but confirm.
