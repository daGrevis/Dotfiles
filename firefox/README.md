# Firefox

## About

Web browser. This file records my theme, my add-ons and how I apply my prefs.

## Theme

[Dark space - The best dynamic theme](https://addons.mozilla.org/en-US/firefox/addon/nicothin-space/)

## Add-ons

- [Consent-O-Matic](https://addons.mozilla.org/en-US/firefox/addon/consent-o-matic/)
- [Dark Reader](https://addons.mozilla.org/en-US/firefox/addon/darkreader/)
- [Don't Fuck With Paste](https://addons.mozilla.org/en-US/firefox/addon/don-t-fuck-with-paste/)
- [Firefox Multi-Account Containers](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/)
- [Pinboard WebExtension](https://addons.mozilla.org/en-US/firefox/addon/pinboard-webextension/)
- [Preact Developer Tools](https://addons.mozilla.org/en-US/firefox/addon/preact-devtools/)
- [React Developer Tools](https://addons.mozilla.org/en-US/firefox/addon/react-devtools/)
- [Simple Translate](https://addons.mozilla.org/en-US/firefox/addon/simple-translate/)
- [Tridactyl](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/)
- [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)

## Prefs

`user.js` contains the prefs that I changed in `about:config`. Firefox reads
`user.js` from the profile directory at each start. `home.nix` finds the
profile directory in `profiles.ini` and links `user.js` into it. The link goes
to this directory, so a change to `user.js` applies at the next start without a
rebuild.

If Firefox did not start on a machine yet, it has no `profiles.ini`. Start
Firefox one time. Then run `home-manager switch` again.

If you change one of these prefs in Firefox, the change does not stay. At the
next start, `user.js` sets the pref back. A pref that you remove from `user.js`
keeps its last value.

To keep a change, edit `user.js`. To reset a pref that you removed, use
`about:config`.
