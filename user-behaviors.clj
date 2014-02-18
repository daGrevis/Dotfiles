{:+ {
     ;; The app tag is kind of like global scope. You assign behaviors that affect
     ;; all of Light Table here
     :app [(:lt.objs.style/set-skin "dark")]

     ;; The editor tag is applied to all editors
     :editor [:lt.objs.editor/no-wrap
              (:lt.objs.style/set-theme "base16-dark")
              (:lt.objs.style/font-settings "Hermit" 8 2)]

     ;; Here we can add behaviors to just clojure editors
     :editor.clojure [(:lt.objs.langs.clj/print-length 1000)]}

 ;; You can use the subtract key to remove behavior that may get added by
 ;; another diff
 :- {:app []}}
