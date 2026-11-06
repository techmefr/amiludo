# Privacy policy (draft)

Draft for legal review before publication. It describes what the code does at alpha 0.4.0. Placeholders in square brackets must be filled in by the publisher.

Last updated: [date]
Publisher and data controller: [name, address, contact email]

## Summary

amiLudo is local first. Your games, friends, notes and photos are stored on your device. The app contains no advertising and no analytics or crash-reporting service. A server is only contacted if you choose features that need one: an account, remote evenings, remote rooms or the community catalogue.

## Data stored on your device

- Games, scores, logs, packs, game shelves, friend profiles, evenings you host, memories and photos, and appearance settings. They are kept in a local database. They are not sent anywhere by the app unless you share them.
- You can export all of it as JSON or CSV and delete it from the app with "Erase all my data" (it asks for confirmation, then removes everything stored on the device), by clearing the app data or by uninstalling.

## Camera

The camera is used only to scan QR codes, to join a room or receive a pack or a session. Images are processed on the device and not stored or sent. The camera permission is requested when you open the scanner. The app does not record photos or video through the camera.

## Photos

Memory photos are files you choose with the system file picker. They are stored in the app's local database. They leave the device only if you export a backup or share them yourself. The app does not request access to your photo library.

## Optional account and remote features

The app is built with an optional Supabase project (hosted authentication and database). If the publisher's build does not include it, none of the following exists.

- Account: if you create an account, your email address, a password hash held by the authentication provider, an optional first name and a role flag are processed by Supabase Auth. Sign-in emails (magic link, code, password reset) are sent through the provider.
- Evenings: if you publish an evening, its content (date, place, seats, planned games) and the answers of guests (names and yes, maybe or no) are stored on the server under a short code. Only signed-in accounts can publish, read or answer through the server functions, and the table has row level security. A host can delete an evening.
- Remote rooms: players exchange game messages through a realtime channel named from a code derived from the room code. The host accepts or refuses each player. Messages are relayed, not stored by the app. Known limits: the room code is the only access control, and the channel is not private. Do not put sensitive information in a room.
- Same-Wi-Fi rooms: players on the same local network discover each other with UDP broadcast and exchange messages by WebSocket. This stays on the local network and is not encrypted.
- Offline sharing: a session is encoded in an animated QR code and never goes through a server.

## Other network access

- Community catalogue and links: the app can open web links (for example the project page on GitHub) in your browser.
- Rules links are opened by your browser; the app does not read them.
- Your IP address is visible to the servers you contact, as with any network request.

## What we do not do

- No advertising, no ad identifier, no tracking across apps or sites.
- No third-party analytics or crash reporting.
- No sale or sharing of personal data with data brokers.
- No location data. The app declares a local network usage purpose on iOS only to find rooms on your Wi-Fi.

## Legal basis, retention and your rights

- Account and evening data are processed to provide the service you request (contract). Local data is processed only on your device.
- Evening data stays until the host deletes it. Account data stays until the account is deleted; an administrator or the account itself can request deletion. [Define retention periods and a deletion procedure.]
- Under the GDPR you may access, correct, delete, export and object to processing, and lodge a complaint with your supervisory authority (in France, the CNIL). Contact: [email].

## Children

The app is not directed at children under 13 and does not knowingly collect their data. Account creation requires an email address. [Confirm the age rating and the age limit for accounts.]

## Processors

Supabase (authentication, database, realtime and edge functions), hosting region [region]. Email delivery is through the provider's sending service or the publisher's SMTP [confirm]. Distribution through Google Play or the Apple App Store is subject to those companies' own policies.

## Security

Transport is over HTTPS to the server. Photos in the shared gallery use encryption (sealed boxes). Local data is not encrypted by the app beyond the operating system's device protection. Keep device backups in a safe place.

## Changes

Changes will be published here with a new date.
