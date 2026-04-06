-- Havoc | Orca Fork (Integrated v2.4 Logic)
local success, err = pcall(function()
    local source = game:HttpGetAsync(
        "https://raw.githubusercontent.com/apxllo1/havoc-orca/main/orca.lua"
    )
    loadstring(source)()
end)

if not success then
    warn("[Havoc] Failed to load: " .. tostring(err))
end
