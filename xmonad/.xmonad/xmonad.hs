import XMonad
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.EZConfig
import XMonad.Hooks.EwmhDesktops


term = "urxvt"
spawn_term = \s -> spawn $ term ++ " -e " ++ s

main = do
    xmonad $ defaultConfig
        {
          modMask = mod4Mask
        , terminal = term
        , XMonad.borderWidth = 3
        , XMonad.normalBorderColor = "#333333"
        , XMonad.focusedBorderColor = "#1793d1"
        , layoutHook = avoidStruts . smartBorders $ layoutHook defaultConfig
        , manageHook = composeAll [ isFullscreen --> doFullFloat, manageDocks ]
        , handleEventHook = fullscreenEventHook <+> handleEventHook defaultConfig
        , focusFollowsMouse = False
        }
        `additionalKeysP`
        [
          ("M-p", spawn "dmenu_run -b -nb '#333333' -nf white -sb '#1793d1' -sf white") -- Opens menu.

        , ("M-S-l", spawn "xscreensaver-command -lock") -- Starts the screensaver.

        , ("M-<Return>", spawn "xterm -e bash") -- Opens the fallback terminal.
        , ("M-S-v", spawn "gvim") -- Opens the ultimate text editor.
        , ("M-S-i", spawn "chromium") -- Opens the browser.
        , ("M-C-i", spawn "chromium --incognito") -- Opens browser the in incognito mode.
        , ("M-S-s", spawn "skype") -- Opens Skype.
        , ("M-C-s", spawn "skype --dbpath=~/.Skype2") -- Opens the 2nd instance of Skype.
        , ("M-S-x", spawn "hexchat") -- Opens the IRC client.
        , ("M-S-b", spawn "transmission-gtk") -- Opens the torrent client.
        , ("M-S-e", spawn "mousepad") -- Opens the text editor.
        , ("M-S-r", spawn_term "ranger") -- Opens the file browser.
        , ("M-S-t", spawn "thunar") -- Opens another file browser.
        , ("M-S-d", spawn_term "glances") -- Opens the system profiler.
        , ("M-S-m", spawn_term "alsamixer") -- Opens the sound mixer.
        , ("M-S-a", spawn_term "ipython2") -- Opens iPython (for Py2).

        , ("<Print>", spawn "scrot '%Y-%m-%d_%X__$wx$h.jpg' -q 90 -e 'mv $f ~/Screenshots/'") -- Takes screenshot.
        , ("M-S-<Print>", spawn "scrot '%Y-%m-%d_%X__$wx$h.png' -q 100 -e 'mv $f ~/Screenshots/'") -- Takes screenshot in HQ.
        , ("M-<Print>", spawn "sleep 0.2; scrot '%Y-%m-%d_%X__$wx$h.jpg' -q 90 -e 'mv $f ~/Screenshots/' -s") -- Takes screenshot by selecting area.

        , ("M-,", spawn "Scripts/toggle_trackpad.sh") -- Toggles trackpad.

        , ("M-[", spawn "Scripts/decrement_brightness.sh") -- Decrements brightness.
        , ("M-]", spawn "Scripts/increment_brightness.sh") -- Increments brightness.
        ]
