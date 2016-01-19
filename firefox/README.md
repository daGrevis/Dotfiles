# [Dotfiles](https://github.com/daGrevis/Dotfiles)

## Firefox

[Pentadactyl add-on](http://5digits.org/home) makes your browser more like Vim!

You may want to compile it yourself to get it working with the latest Firefox.

    git clone https://github.com/5digits/dactyl
    cd dactyl
    make -C pentadactyl install

Unfortunately you will have to enable `xpinstall.signatures.required` config
flag if you are using Firefox 43.

##### Other Add-ons You Might Enjoy

* [Disconnect](https://addons.mozilla.org/en-us/firefox/addon/disconnect/),
* [HTTPS Everywhere](https://addons.mozilla.org/en-us/firefox/addon/https-everywhere/),
* [JSONView](https://addons.mozilla.org/en-us/firefox/addon/jsonview/),
* [Reddit Enhancement Suite](https://addons.mozilla.org/en-US/firefox/addon/reddit-enhancement-suite/),
* [Self-Destructing Cookies](https://addons.mozilla.org/En-us/firefox/addon/self-destructing-cookies/),
* [YouTube High Definition](https://addons.mozilla.org/En-us/firefox/addon/youtube-high-definition/);

##### Config Flags

    services.sync.enabled;false
    signon.rememberSignons;false
    browser.tabs.closeWindowWithLastTab;false
