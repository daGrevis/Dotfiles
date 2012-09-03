import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Util.EZConfig
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Layout.NoBorders

main = do
    conf <- dzen defaultConfig
    xmonad $ conf
        {
          terminal = "urxvt"
        , layoutHook                = smartBorders (layoutHook conf)
        , XMonad.borderWidth        = 4
        , XMonad.normalBorderColor  = "black"
        , XMonad.focusedBorderColor = "#1793d1"
        }
         `additionalKeysP`
        [
          ("M-S-<Return>", spawn "urxvt -lsp 2 -bc")
        , ("M-p",          spawn "`yeganesh -x -- -i -nb black -nf white -sb \"#1793d1\" -sf white`")
        , ("<Print>",      spawn "scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/Screenshots/'")
        , ("M-S-<Print>",  spawn "scrot '%Y-%m-%d_$wx$h.png' -s -e 'mv $f ~/Screenshots/'") -- Doesn't work!
        , ("M-S-l",        spawn "xscreensaver-command -lock")
        , ("M-S-i",        spawn "chromium")
        ]
