local jid_split = require "util.jid".split;
local fire_event = prosody.events.fire_event;

local shard_name = module:get_option("shard_name", nil);
if not shard_name then
    error("shard_name not configured", 0);
end

module:log("info", "%s added to shard %s", module.host, shard_name);

local XXX_user_shard = {};
XXX_user_shard['robn@localhost'] = 's1';
XXX_user_shard['other@localhost'] = 's2';

local function handle_event (event)
    local to = event.stanza.attr.to;
    local node, host = jid_split(to);

    if not node or not host then
        return nil
    end
    if host ~= module.host then
        return nil
    end

    local user = node.."@"..host;

    if prosody.bare_sessions[user] then
        module:log("debug", user.." has a session here, nothing to do");
        return nil
    end

    module:log("debug", "looking up target shard for "..user);

    -- XXX do the real lookup
    local shard = XXX_user_shard[user]
    if not shard then
        error("shard lookup for "..user.." failed!");
    end

    module:log("debug", "target shard for "..user.." is "..shard);

    if shard == shard_name then
        module:log("debug", "we are shard "..shard..", nothing to do");
        return nil;
    end

    fire_event("shard/send", { shard = shard, stanza = event.stanza });

    return true;
end

module:hook("iq/bare", handle_event, 1000);
module:hook("message/bare", handle_event, 1000);
module:hook("presence/bare", handle_event, 1000);
module:hook("iq/full", handle_event, 1000);
module:hook("message/full", handle_event, 1000);
module:hook("presence/full", handle_event, 1000);
module:hook("iq/host", handle_event, 1000);
module:hook("message/host", handle_event, 1000);
module:hook("presence/host", handle_event, 1000);
