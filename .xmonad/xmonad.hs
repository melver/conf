--
-- xmonad.hs
--

import XMonad
import XMonad.Layout
import XMonad.Hooks.ManageDocks
import XMonad.Config (defaultConfig)
import XMonad.Actions.GridSelect
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog hiding (xmobar)
import XMonad.Actions.CycleWS
import qualified Data.Map as M
import XMonad.Util.Run (spawnPipe)
import System.IO (hPutStrLn)
import Graphics.X11

import Text.Regex.Posix ((=~))
q ~? x = fmap (=~ x) q

main :: IO ()
main = do
        xmobar <- spawnPipe "xmobar"
        xmonad defaultConfig
         { normalBorderColor  = "#222222"
         , focusedBorderColor = "#EF2929"
         , borderWidth        = 1
         , terminal = "term"
         , logHook = dynamicLogWithPP defaultPP { ppTitle  = shorten 90
                                                , ppLayout = (>> "")
                                                , ppOutput = hPutStrLn xmobar }
         , layoutHook = avoidStruts ( smartBorders (Full ||| Mirror tiled ))
         , manageHook = composeOne [ isFullscreen -?> doFullFloat,
                                     isDialog     -?> doCenterFloat ]
                        <+> composeAll [ className =? "fontforge" --> doFloat,
                                         className =? "MPlayer"   --> doFloat,
                                         title     =? "glxgears"  --> doFloat,
                                         className ~? "Gimp"      --> doFloat,
                                         className ~? "Skype"     --> doFloat,
                                         className =? "Pidgin"    --> doFloat,
                                         className =? "Vlc"       --> doFloat,
                                         className =? "Xmessage"  --> doCenterFloat,
                                         className =? "Gxmessage"  --> doCenterFloat  ]
                        <+> manageDocks
         , keys = \c -> mykeys c `M.union` keys defaultConfig c
         , modMask = mod4Mask -- use Windows key as mod
         }
  where
     tiled   = Tall nmaster delta ratio
 
     -- The default number of windows in the master pane
     nmaster = 1
 
     -- Default proportion of screen occupied by master pane
     ratio   = toRational (2/(1+sqrt(5)::Double)) -- golden
 
     -- Percent of screen to increment by when resizing panes
     delta   = 0.03
 
     mykeys (XConfig {XMonad.modMask = modm}) = M.fromList $
             [ ((controlMask .|. modm, xK_Right), nextWS)
             , ((controlMask .|. modm, xK_Left),  prevWS)
             , ((modm, xK_g), goToSelected defaultGSConfig)
             , ((modm, xK_b), sendMessage ToggleStruts)
             , ((modm, xK_p), spawn "exe=`$HOME/0wnfiles/coding/python/lib/dmenu-apps.py echo` && eval \"exec $exe\"")
             , ((modm, xK_f), spawn "chromium --disk-cache-size=268435456")
             , ((modm, xK_e), spawn "thunderbird")
             , ((controlMask .|. modm, xK_l), spawn "$HOME/0wnfiles/coding/shell/xlock-screenoff.sh") ]
