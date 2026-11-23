--
-- Cozy theme menu for Elephant/Walker
--
Name = "cozythemes"
NamePretty = "Cozy Themes"
HideFromProviderlist = true

local function file_exists(path)
  local f = io.open(path, "r")
  if f then
    f:close()
    return true
  end
  return false
end

-- Return the first image inside a directory, if any.
local function first_image_in_dir(dir)
  local handle = io.popen("find -L '" .. dir .. "' -maxdepth 1 -type f "
    .. "\\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' "
    .. "-o -iname '*.webp' -o -iname '*.gif' \\) 2>/dev/null | sort | head -n 1")
  if handle then
    local file = handle:read("*l")
    handle:close()
    if file and file ~= "" then
      return file
    end
  end
  return nil
end

-- Find a preview for a theme: preview image first, then a wallpaper.
local function find_preview_path(dir)
  for _, name in ipairs({ "preview.png", "preview.jpg", "preview.jpeg", "preview.webp" }) do
    local path = dir .. "/" .. name
    if file_exists(path) then return path end
  end
  return first_image_in_dir(dir) or first_image_in_dir(dir .. "/Walls")
end

local function pretty_name(name)
  local display = name:gsub("_", " "):gsub("%-", " ")
  display = display:gsub("(%a)([%w_']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
  return display
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")
  local theme_dirs = {
    home .. "/.local/share/Cozy/Themes",
    home .. "/.config/Cozy/themes",
  }

  local seen = {}

  for _, theme_dir in ipairs(theme_dirs) do
    local handle = io.popen("find -L '" .. theme_dir .. "' -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort")
    if handle then
      for theme_path in handle:lines() do
        local theme_name = theme_path:match(".*/(.+)$")
        if theme_name and not seen[theme_name] then
          seen[theme_name] = true
          local preview_path = find_preview_path(theme_path)
          if preview_path then
            table.insert(entries, {
              Text = pretty_name(theme_name) .. "  ",
              Preview = preview_path,
              PreviewType = "file",
              Actions = {
                activate = "cozy-theme-apply '" .. theme_name .. "'",
              },
            })
          end
        end
      end
      handle:close()
    end
  end

  return entries
end
