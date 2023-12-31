
local redraw_timer=function(player,time)
    local seconds=time%60
    local total_minutes=math.floor(time/60)
    local minutes=total_minutes % 60
    local hours=math.floor(total_minutes/60)

    local time_string=string.format("%02d:%02d:%.2f",hours,minutes,seconds)

    local timer_hud_id=player:get_meta():get_int("speedrun_timer_hud_id")
    if player:hud_get(timer_hud_id) and player:hud_get(timer_hud_id).name=="speedrun_timer" then
        player:hud_change(timer_hud_id,"text",time_string)
    else
        timer_hud_id=player:hud_add({
            type="text",
            text=time_string,
            position={x=1,y=0.5},
            alignment={x=-1,y=0},
            size={x=3,y=3},
            number=0xFFFFFF,
            style=1+4,
            name="speedrun_timer",
        })
        player:get_meta():set_int("speedrun_timer_hud_id",timer_hud_id)
    end
end

minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local timer_active=player:get_meta():get_int("speedrun_timer_active")
        local control_bits=player:get_player_control_bits()
        local timer_value=player:get_meta():get_float("speedrun_timer_value")
        if timer_active~=0 then
            player:get_meta():set_float("speedrun_timer_value",timer_value+dtime)
            redraw_timer(player,timer_value)
            --Keybind for stopping timer is Shift+E (sneak+aux1)
            if control_bits==2^5+2^6 then 
                player:get_meta():set_int("speedrun_timer_active",0)
            end
        else
            --Do not automatically start timer if it is nonzero (When Shift+E is being pressed to stop the timer, it would start it again)
            if control_bits~=0 and timer_value==0 then
                player:get_meta():set_int("speedrun_timer_active",1)
            end
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    local timer_value=player:get_meta():get_float("speedrun_timer_value")
    redraw_timer(player,timer_value)
end)

minetest.register_chatcommand("stop",{
    description="Stop the speedrun timer",
    func=function(name)
        local player=minetest.get_player_by_name(name)
        player:get_meta():set_int("speedrun_timer_active",0)
    end
})

minetest.register_chatcommand("start",{
    description="Manually start the speedrun timer",
    func=function(name)
        local player=minetest.get_player_by_name(name)
        player:get_meta():set_int("speedrun_timer_active",1)
    end
})

minetest.register_chatcommand("reset",{
    description="Reset the speedrun timer",
    func=function(name)
        local player=minetest.get_player_by_name(name)
        player:get_meta():set_int("speedrun_timer_active",0)
        player:get_meta():set_float("speedrun_timer_value",0)
        redraw_timer(player,0)
    end
})