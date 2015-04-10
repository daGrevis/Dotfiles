{:user {:plugins [[lein-exec "0.3.4"]
                  [lein-midje "3.1.1"]
                  [criterium "0.4.3"]
                  [venantius/ultra "0.1.9"]
                  [cider/cider-nrepl "0.8.2"]
                  [jonase/eastwood "0.2.1"]]
        :ultra {:color-scheme :solarized_dark}
        :eastwood {:exclude-linters [:unlimited-use]}}}

(use '[leiningen.exec :only (deps)])
