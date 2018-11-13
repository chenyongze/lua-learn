---
--- Generated by dotalk.cn
--- Created by yongze.chen
--- DateTime: 2018/9/23 下午11:58
---

--#!/usr/bin/env lua
local log_req = function(premature, data)
    local ip, port = '192.168.1.83', 8125
    local sock = ngx.socket.udp()
    sock:setpeername(ip, port)
    sock:send(data)
    sock:close()
end

call_statsd = function(name, hostname)
    name=string.gsub(name,'%.','_')
    if ngx.var.user_agent and ngx.var.user_agent:find('JianKongBao Monitor') then
        return
    end
    local prefix = 'srv.nginx.' .. name .. '.' .. hostname .. '.'
    local status = ngx.status
    local data_s = prefix .. 'requests.'.. status ..':1|c'
    ngx.timer.at(0, log_req, data_s)
    local time = ngx.var.upstream_response_time
    if time then
        time = time:gsub(',.*', '')
        if tonumber(time) then
            local data_t = prefix .. 'time:' .. (tonumber(time) * 1000) .. '|ms'
            ngx.timer.at(0, log_req, data_t)
        end
    end
end

--[[

usage:

添加到 http 节：

  init_by_lua_file stats.lua; # This file

添加到相应 server / location 节，如：

  log_by_lua 'call_statsd("www", "bj-yj-www01")';

]]