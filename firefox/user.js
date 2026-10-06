// Prefs that I changed in about:config. Firefox reads this file from the
// profile directory at each start. home.nix links it there. The defaults in the
// comments are from Firefox 157.

// Interface

// about:config opens without a warning. Default: true.
user_pref("browser.aboutConfig.showWarning", false);
// The bookmarks toolbar is hidden. Default: "newtab".
user_pref("browser.toolbars.bookmarks.visibility", "never");
// Firefox does not offer to translate Latvian pages. Default: "".
user_pref("browser.translations.neverTranslateLanguages", "lv");
// The address bar shows a maximum of 3 results. Default: 10.
user_pref("browser.urlbar.maxRichResults", 3);
// Cmd+Q quits without a warning. Default: true.
user_pref("browser.warnOnQuitShortcut", false);
// The find bar highlights all matches. Default: false.
user_pref("findbar.highlightAll", true);
// Full screen opens and closes without an animation. Default: "200 200".
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");

// AI

// The AI chatbot is blocked. Default: "default".
user_pref("browser.ai.control.sidebarChatbot", "blocked");
// The AI chatbot is off. Default: true.
user_pref("browser.ml.chat.enabled", false);
// The page menu has no AI chatbot items. Default: true.
user_pref("browser.ml.chat.page", false);

// Sponsored content

// Firefox does not recommend add-ons. Default: true.
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
// Firefox does not recommend features. Default: true.
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
// The new tab page has no sponsored stories. Default: true.
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
// The new tab page has no sponsored shortcuts. Default: true.
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

// Passwords and forms

// Firefox does not save or fill payment methods. Default: true.
user_pref("extensions.formautofill.creditCards.enabled", false);
// Firefox does not show alerts about breached websites. Default: true.
user_pref("signon.management.page.breach-alerts.enabled", false);
// Firefox does not ask to save passwords. Default: true.
user_pref("signon.rememberSignons", false);

// Prefetch

// Firefox does not resolve the DNS of links before a click. Default: false.
user_pref("network.dns.disablePrefetch", true);
// Firefox does not open connections before a click. Default: 20.
user_pref("network.http.speculative-parallel-limit", 0);
// Firefox does not load the pages that a website marks for prefetch. Default:
// true.
user_pref("network.prefetch-next", false);

// Telemetry

// Firefox does not install studies. Default: true.
user_pref("app.shield.optoutstudies.enabled", false);
// Firefox does not send technical data. Default: true.
user_pref("datareporting.healthreport.uploadEnabled", false);
// Firefox does not send usage data. Default: true.
user_pref("datareporting.usage.uploadEnabled", false);
// Firefox does not enable remote rollouts. Default: true.
user_pref("nimbus.rollouts.enabled", false);

// DevTools

// The HTTP cache is off while DevTools is open. Default: false.
user_pref("devtools.cache.disabled", true);
// The inspector has two panes. Default: true.
user_pref("devtools.inspector.three-pane-enabled", false);
// DevTools opens on the right side. Default: "bottom".
user_pref("devtools.toolbox.host", "right");
// The console does not show results before Enter. Default: true.
user_pref("devtools.webconsole.input.eagerEvaluation", false);
