﻿--[[--
Multi-language phrase support.

Lilia has support for multiple languages, and you can easily leverage this system for use in your own schema, plugins, etc.
Languages will be loaded from the schema and any plugins in `languages/sh_languagename.lua`, where `languagename` is the id of a
language (`english` for English, `french` for French, etc). The structure of a language file is a table of phrases with the key
as its phrase ID and the value as its translation for that language. An example
LANGUAGE = {
    welcomeMessage = "Welcome to the game!",
    gameOver = "Game over! You won the game!",
    victory = "%s achieved victory!",
}

The phrases defined in these language files can be used with the `L` global function:
	print(L("welcomeMessage"))
	> "Welcome to the game!"

All phrases are formatted with `string.format`, so if you wish to add some info in a phrase you can use standard Lua string
formatting arguments:
	print(L("victory", "Nicholas"))
	> Nicholas achieved victory!
]]
-- @library lia.lang
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--- Loads language files from a directory.
-- @realm shared
-- @string directory Directory to load language files from
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        lia.include(directory .. "/" .. v, "shared")
        if LANGUAGE then
            if NAME then
                lia.lang.names[niceName] = NAME
                NAME = nil
            end

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, LANGUAGE)
            LANGUAGE = nil
        end
    end
end

--- Adds a table of phrases to a language.
-- @realm shared
-- @string name The name of the language to add the phrases to.
-- @tab tbl The table of phrases to add.
function lia.lang.AddTable(name, tbl)
    lia.lang.stored[name] = table.Merge(lia.lang.stored[name] or {}, tbl)
end

--- Retrieves a localized string based on the specified key and the default language setting.
-- @string key The key corresponding to the desired localized string.
-- @tab ... Additional parameters to format the localized string.
-- @return The formatted localized string.
-- @realm shared
function L(key, ...)
    local languages = lia.lang.stored
    local langKey = lia.config.Language
    local info = languages[langKey] or languages.english
    return string.format(info and info[key] or key, ...)
end

lia.lang.loadFromDir("lilia/gamemode/languages")