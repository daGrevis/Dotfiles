{:user {:plugins [[lein-exec "0.3.1"]]}}
(use '[leiningen.exec :only (deps)])
(deps '[[ring/ring-core "1.0.0"]
        [ring/ring-jetty-adapter "1.0.0"]])
