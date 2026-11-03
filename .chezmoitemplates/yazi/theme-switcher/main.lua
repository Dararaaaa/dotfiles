--- @sync entry
-- ============================================
-- Yazi 主题切换插件
-- 位置: 当前平台的 Yazi 配置目录/plugins/theme-switcher.yazi/main.lua
-- 用途: 快速切换 Yazi 主题
-- ============================================

local themes = {
    "tokyo-night",         -- 默认 Tokyo Night
    "tokyo-night-storm",   -- Tokyo Night Storm (更深背景)
    "catppuccin-mocha",    -- Catppuccin Mocha (温暖柔和)
    "gruvbox-dark",        -- Gruvbox Dark (复古)
    "nord",                -- Nord (冷色调)
}

local current_theme_index = 1

local function config_dir()
    local explicit = os.getenv("YAZI_CONFIG_HOME")
    if explicit and explicit ~= "" then
        return explicit:gsub("\\", "/")
    end

    local appdata = os.getenv("APPDATA")
    if appdata and appdata ~= "" then
        return appdata:gsub("\\", "/") .. "/yazi"
    end

    local xdg_config = os.getenv("XDG_CONFIG_HOME")
    if xdg_config and xdg_config ~= "" then
        return xdg_config:gsub("\\", "/") .. "/yazi"
    end

    local home = os.getenv("USERPROFILE") or os.getenv("HOME")
    if not home then
        return nil
    end
    return home:gsub("\\", "/") .. "/.config/yazi"
end

local function copy_file(source, destination)
    local input = io.open(source, "rb")
    if not input then
        return false
    end

    local output = io.open(destination, "wb")
    if not output then
        input:close()
        return false
    end

    output:write(input:read("*a"))
    input:close()
    output:close()
    return true
end

-- 💡 读取当前主题配置
local function get_current_theme()
    local dir = config_dir()
    if not dir then
        return "tokyo-night"
    end

    local config_path = dir .. "/theme.toml"
    local file = io.open(config_path, "r")
    if not file then
        return "tokyo-night"
    end
    
    local content = file:read("*all")
    file:close()
    
    -- 从配置文件中提取主题名称
    local theme = content:match('use = "([^"]+)"')
    return theme or "tokyo-night"
end

-- 💡 应用新主题
local function apply_theme(theme_name)
    local dir = config_dir()
    if not dir then
        ya.err("找不到 Yazi 配置目录")
        return false
    end

    local themes_dir = dir .. "/themes"
    local config_path = dir .. "/theme.toml"
    local theme_file = themes_dir .. "/" .. theme_name .. ".toml"
    
    -- 检查主题文件是否存在
    local file = io.open(theme_file, "r")
    if not file then
        ya.err("主题文件不存在: " .. theme_file)
        return false
    end
    file:close()
    
    -- 直接复制文件，避免依赖 Unix 的 cp 命令。
    if not copy_file(theme_file, config_path) then
        ya.err("无法写入主题配置: " .. config_path)
        return false
    end
    
    ya.dbg("已切换到主题: " .. theme_name)
    return true
end

-- 💡 切换到下一个主题
local function next_theme()
    current_theme_index = current_theme_index + 1
    if current_theme_index > #themes then
        current_theme_index = 1
    end
    
    local theme = themes[current_theme_index]
    if apply_theme(theme) then
        ya.notify {
            title = "主题切换",
            content = "已切换到: " .. theme,
            timeout = 2,
        }
    end
end

-- 💡 切换到上一个主题
local function prev_theme()
    current_theme_index = current_theme_index - 1
    if current_theme_index < 1 then
        current_theme_index = #themes
    end
    
    local theme = themes[current_theme_index]
    if apply_theme(theme) then
        ya.notify {
            title = "主题切换",
            content = "已切换到: " .. theme,
            timeout = 2,
        }
    end
end

-- 💡 显示主题选择菜单
local function show_theme_menu()
    local options = {}
    for i, theme in ipairs(themes) do
        table.insert(options, theme)
    end
    
    ya.dbg("可用主题: " .. table.concat(options, ", "))
    
    -- 提示用户手动选择主题
    ya.notify {
        title = "主题列表",
        content = "共 " .. #themes .. " 个主题可用\n使用 <Space>tn/tp 切换",
        timeout = 3,
    }
end

-- 💡 插件入口函数
return {
    entry = function(state, args)
        local action = args and args[1] or "menu"
        
        if action == "next" then
            next_theme()
        elseif action == "prev" then
            prev_theme()
        else
            show_theme_menu()
        end
    end,
}
