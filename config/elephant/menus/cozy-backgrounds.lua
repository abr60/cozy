--
-- Cozy background menu for Elephant/Walker
--
Name = "cozybackgrounds"
NamePretty = "Cozy Backgrounds"
Cache = false
HideFromProviderlist = true
SearchName = true

local function shell_escape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function format_name(filename)
  local name = filename:gsub("^%d+", ""):gsub("^%-", "")
  name = name:gsub("%.[^%.]+$", "")
  name = name:gsub("-", " ")
  name = name:gsub("%S+", function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
  return name
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")

  local theme_file = io.open(home .. "/.local/state/Cozy/current-theme", "r")
  local theme_name = theme_file and theme_file:read("*l") or nil
  if theme_file then
    theme_file:close()
  end

  local dirs = {}
  if theme_name and theme_name ~= "" then
    table.insert(dirs, home .. "/.local/share/Cozy/Themes/" .. theme_name .. "/Walls")
    table.insert(dirs, home .. "/.config/Cozy/themes/" .. theme_name .. "/Walls")
    table.insert(dirs, home .. "/Walls/" .. theme_name)
  end

  local seen = {}

  for _, wallpaper_dir in ipairs(dirs) do
    local handle = io.popen(
      "find -L " .. shell_escape(wallpaper_dir)
        .. " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' "
        .. "-o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \\) 2>/dev/null | sort"
    )
    if handle then
      for background in handle:lines() do
        local filename = background:match("([^/]+)$")
        if filename and not seen[filename] then
          seen[filename] = true
          table.insert(entries, {
            Text = format_name(filename),
            Value = background,
            Preview = background,
            PreviewType = "file",
            Actions = {
              activate = "cozy-bg-apply " .. shell_escape(background),
            },
          })
        end
      end
      handle:close()
    end
  end

  return entries
end
