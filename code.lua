local addonName = ...

local select, find, lower, wipe, prn = select, string.find, string.lower, table.wipe, print

local LISTENING = false

local addon = CreateFrame('Frame', addonName)
local orig = UIErrorsFrame:GetScript('OnEvent')
local db

local printPrefix = '|cff66cc33'..addonName..'|r: '
local function print(...)
    prn(printPrefix, ...)
end

local function add(...)
    local msg
    for i = 1, select('#', ...) do
        msg = select(i, ...)
        if msg then
            --print('Added|cff95ff95', lower(msg), '|rto database.')
            db[lower(msg)] = true
        else
            print('key '..i..' is nil!!!')
        end
    end
end

local function defaults()
    db = db and wipe(db) or {}
    add(
        ERR_ABILITY_COOLDOWN,
        ERR_ATTACK_CHANNEL,
        ERR_ATTACK_CHARMED,
        ERR_ATTACK_CONFUSED,
        ERR_ATTACK_DEAD,
        ERR_ATTACK_FLEEING,
        ERR_ATTACK_MOUNTED,
        ERR_ATTACK_STUNNED,
        ERR_BADATTACKFACING,
        ERR_BADATTACKPOS,
        --ERR_BUTTON_LOCKED,
        ERR_CLIENT_LOCKED_OUT,
        ERR_EAT_WHILE_MOVNG,
        ERR_GENERIC_NO_TARGET,
        --ERR_GENERIC_NO_VALID_TARGETS,
        ERR_GENERIC_STUNNED,
        --ERR_INVALID_ATTACK_TARGET,
        ERR_ITEM_COOLDOWN,
        --ERR_MUST_EQUIP_ITEM,
        ERR_NOEMOTEWHILERUNNING,
        ERR_OUT_OF_CHI,
        ERR_OUT_OF_DARK_FORCE,
        ERR_OUT_OF_DEMONIC_FURY,
        ERR_OUT_OF_ENERGY,
        ERR_OUT_OF_FOCUS,
        --ERR_OUT_OF_HEALTH,
        ERR_OUT_OF_HOLY_POWER,
        --ERR_OUT_OF_LIGHT_FORCE,
        ERR_OUT_OF_MANA,
        ERR_OUT_OF_RAGE,
        ERR_OUT_OF_RANGE,
        ERR_OUT_OF_RUNES,
        ERR_OUT_OF_RUNIC_POWER,
        ERR_OUT_OF_SHADOW_ORBS,
        ERR_OUT_OF_SOUL_SHARDS,
        ERR_PET_SPELL_DEAD,
        ERR_PET_SPELL_NOT_BEHIND,
        ERR_PET_SPELL_OUT_OF_RANGE,
        ERR_PET_SPELL_ROOTED,
        ERR_PET_SPELL_TARGETS_DEAD,
        ERR_PLAYER_DEAD,
        ERR_POTION_COOLDOWN,
        ERR_SPELL_COOLDOWN,
        ERR_SPELL_OUT_OF_RANGE,
        --ERR_TARGET_STUNNED,
        ERR_USE_BAD_ANGLE,
        ERR_USE_TOO_FAR,
        ERR_TOO_FAR_TO_ATTACK,

        ERR_NO_ATTACK_TARGET,

        SPELL_FAILED_BAD_IMPLICIT_TARGETS,
        SPELL_FAILED_CASTER_DEAD,
        SPELL_FAILED_CASTER_DEAD_FEMALE,
        SPELL_FAILED_CUSTOM_ERROR_141, -- you are facing the wrong way
        SPELL_FAILED_CHARMED,
        SPELL_FAILED_CONFUSED,
        SPELL_FAILED_FALLING,
        SPELL_FAILED_FIZZLE,
        SPELL_FAILED_FLEEING,
        SPELL_FAILED_SPELL_IN_PROGRESS,
        SPELL_FAILED_OUT_OF_RANGE,
        SPELL_FAILED_PACIFIED,
        SPELL_FAILED_ROOTED,
        SPELL_FAILED_SILENCED,
        SPELL_FAILED_SPELL_IN_PROGRESS,
        SPELL_FAILED_STUNNED,
        SPELL_FAILED_INTERRUPTED,
        SPELL_FAILED_CASTER_AURASTATE,
        SPELL_FAILED_TARGET_AURASTATE,
        SPELL_FAILED_TARGETS_DEAD,
        SPELL_FAILED_MOVING,
        SPELL_FAILED_NOTHING_TO_DISPEL,
        SPELL_FAILED_NOT_BEHIND,
        SPELL_FAILED_NOT_INFRONT,
        SPELL_FAILED_NOT_IN_CONTROL,
        SPELL_FAILED_NOT_READY,
        SPELL_FAILED_NO_COMBO_POINTS
    )
    return db
end


local function slash(str)
    str = lower(str)
    if(str == 'reset') then
        ErrorsAwayDB = defaults()
        db = ErrorsAwayDB
        print('Database was reset.')
    elseif(str == 'list') then
        if next(db) then
            print('Listing database:')
            for k, v in pairs(db) do
                prn('     |cff95ff95', k, '|r')
            end
        else
            print('Database is empty.')
        end
    elseif(str == 'listen') then
        LISTENING = not LISTENING
        print('Listening to any errors now', LISTENING and '|cff00ff00enabled|r.' or '|cffff0000disabled|r.')
    elseif(#str > 0) then
        if db[str] then
            db[str] = nil
            return print('Removed|cff95ff95', v, '|rfrom database.')
        end

        db[str] = true
        print('Added|cff95ff95', str, '|rto database.')
    else
        print(' Commands:')
        prn('     |cff95ff95/'..lower(addonName)..' reset|r    Resets the database to default errors.')
        prn('     |cff95ff95/'..lower(addonName)..' list|r     Lists the entries in the database.')
        prn('     |cff95ff95/'..lower(addonName)..' listen|r   Listen to the errorsframe and add errors automatically.')
        prn('     |cff95ff95/'..lower(addonName)..' <text>|r   Adds <text> to the database.')
    end
end

local function errorEvent(self, event, str, ...)
    if(event == 'UI_ERROR_MESSAGE') then
        if db[lower(str)] then
            return
        elseif LISTENING then
            db[lower(str)] = true
            return print('Added|cff95ff95', lower(str), '|rto database.')
        end
    end
    return orig(self, event, str, ...)
end

local function addSlash(name, func, ...)
    name = name:upper()
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = lower(select(i, ...))
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end

addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, name)
    if name ~= addonName then return end

    self:UnregisterEvent(event)
    ErrorsAwayDB = ErrorsAwayDB or defaults()
    db = ErrorsAwayDB

    addSlash(addonName, slash, addonName, 'errors')
    addSlash = nil

    UIErrorsFrame:SetScript('OnEvent', errorEvent)
end)
