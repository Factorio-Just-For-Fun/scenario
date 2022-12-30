--- Config file used to enable and disable different push messages for discord
-- @config Discord-Alerts

return {
    show_playtime=true,
    entity_protection=true,
    player_reports=true,
    player_warnings=true,
    player_bans=true,
    player_mutes=true,
    player_kicks=true,
    player_jail=true,

    player_promotes=false, -- This just causes spam
    
    ['config']=true,
    ['permissions']=true,
    ['editor']=true,
    
    ['purge']=true,
    ['banlist']=true,

    ['cheat']=true,
    ['c']=true,
    ['command']=true,
    ['sc']=true,
    ['silent-command']=true,
    ['measured-command']=true,

    ['open']=true,
    ['o']=true,
    
    ['repair']=true,
    ['disable-pollution']=true,
    ['waterfill']=true,
}
