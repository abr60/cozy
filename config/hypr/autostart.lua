-- Personal autostart processes.
-- These run in addition to Cozy's default autostart.

-- --- System Daemons & Services ---
a.exec_on_start("ollama serve")
a.exec_on_start("cozy-earbuds-status")
a.exec_on_start("easyeffects --gapplication-service") -- EasyEffects DSP
--a.exec_on_start("xdg-terminal-exec bash \"$COZY_PATH/post-install.sh\"")
--exec_on_start("kitty --class cava-desktop --override background_opacity=0.0 --override background=#000000 -e cava")
-- --- Commented / Optional ---
-- a.exec_on_start("qs -c ii")
-- a.exec_on_start("cozy-battery-monitor")
-- a.exec_on_start("cozy-inject.sh")

--a.exec_on_start("sleep 1 && paplay ~/.config/hypr/assets/sounds/TempleOS-Hymn-Risen.wav")

-- --- Hyprexpo -- ---
--a.exec_on_start("hyprpm reload")  -- Reload plugins on every boot

