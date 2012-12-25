import XMonad
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.EZConfig


term = "urxvt"
spawn_term = \s -> spawn $ term ++ " -e " ++ s

main = do
    xmonad $ defaultConfig
        {
          modMask = mod4Mask
        , terminal = term
        , XMonad.borderWidth = 4
        , XMonad.normalBorderColor = "#333333"
        , XMonad.focusedBorderColor = "#1793d1"
        -- Show xmobar in front of other windows and don't show window's border if there are only one window at the workspace.
        , layoutHook = avoidStruts $ smartBorders (layoutHook defaultConfig)
        , manageHook = composeAll [ isFullscreen --> doFullFloat ] -- Allows to watch videos in fullscreen, plus, hides Xmobar.
        , focusFollowsMouse = False -- Now the mouse won't change windows focus.
        }
        `additionalKeysP`
        [
          ("M-p", spawn "dmenu_run -b -nb '#333333' -nf white -sb '#1793d1' -sf white") -- Opens menu.
        , ("<Print>", spawn "scrot '%Y-%m-%d_%X__$wx$h.jpg' -q 90 -e 'mv $f ~/Screenshots/'") -- Takes screenshot.
        , ("M-S-l", spawn "xscreensaver-command -lock") -- Starts screensaver.
        , ("M-<Return>", spawn "xterm") -- Opens simple-terminal.
        , ("M-S-v", spawn_term "vim") -- Opens text-editor.
        , ("M-S-d", spawn_term "glances") -- Opens system-profiler.
        , ("M-S-m", spawn_term "alsamixer") -- Opens mixer.
        , ("M-S-i", spawn "luakit") -- Opens browser.
        , ("M-C-i", spawn "chromium --incognito") -- Opens browser in incognito mode.
        , ("M-S-s", spawn "skype") -- Opens IM-client.
        , ("M-S-x", spawn "xchat") -- Opens IRC-client.
        ]
