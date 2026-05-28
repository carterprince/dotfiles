local speed_has_been_set = false

mp.register_event("file-loaded", function()
    -- If we haven't set the speed yet this session...
    if not speed_has_been_set then
        local filename = mp.get_property("filename", "")
        
        -- Check if the file ends in .mp3 (case-insensitive)
        if filename:lower():match("%.mp3$") then
            mp.set_property_number("speed", 1.07)
            speed_has_been_set = true -- Prevent this from ever running again
        end
    end
end)
