import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders

my_terminal = "urxvt -lsp 2 -bc"
term = \s -> spawn $ my_terminal++" -e "++s

main = do
    conf <- dzen defaultConfig
    xmonad $ conf
        {
          terminal = my_terminal
        , layoutHook                = smartBorders (layoutHook conf)
        , XMonad.borderWidth        = 4
        , XMonad.normalBorderColor  = "black"
        , XMonad.focusedBorderColor = "#1793d1"
        }
        `additionalKeysP`
        [
          ("M-S-a",        spawn "subl -n")
        , ("M-S-v",        term  "vim")
        , ("M-S-i",        spawn "chromium")
        , ("M-C-i",        spawn "chromium --incognito")
        , ("M-C-<Delete>", term  "glances")
        , ("M-p",          spawn "`yeganesh -x -- -i -nb black -nf white -sb \"#1793d1\" -sf white`")
        , ("<Print>",      spawn "scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/Screenshots/'")
        , ("M-S-<Print>",  spawn "scrot '%Y-%m-%d_$wx$h.png' -s -e 'mv $f ~/Screenshots/'") -- Doesn't work!
        , ("M-S-l",        spawn "xscreensaver-command -lock")
        ]
