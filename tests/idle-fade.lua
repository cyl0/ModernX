-- Run from the repository root in a disposable mpv instance:
-- mpv --no-config --osc=no --idle=yes --force-window=yes --ao=null \
--   --script=modernx.lua --script=tests/idle-fade.lua \
--   'av://lavfi:testsrc=size=960x540:rate=24'
-- No media files or user configuration are required. Exits 1 on failure.
local mp = require 'mp'

mp.register_event('file-loaded', function()
    mp.add_timeout(0.5, function()
        mp.commandv('script-message', 'osc-visibility', 'always')
    end)
    mp.add_timeout(1.0, function()
        -- Start fading, then enter the idle screen before the fade finishes.
        mp.commandv('script-message', 'osc-visibility', 'auto')
        mp.commandv('stop')
    end)
    mp.add_timeout(1.5, function()
        mp.commandv('script-message', 'osc-visibility', 'always')
    end)
    mp.add_timeout(1.8, function()
        -- A crashed OSC cannot process the second visibility request.
        if mp.get_property_native('user-data/osc/visibility') ~= 'always' then
            mp.msg.error('FAIL: OSC stopped responding after entering idle during a fade')
            mp.commandv('quit', 1)
            return
        end
        mp.msg.info('PASS: OSC responds after entering idle during a fade')
        mp.commandv('quit', 0)
    end)
end)
