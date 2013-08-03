#!/usr/bin/env puma

stage           = ENV['RACK_ENV']
shared_path     = '/home/tryredis/try.redis/shared'
puma_pid        = "#{shared_path}/pids/puma.pid"
puma_sock       = "unix://#{shared_path}/sockets/puma.sock"
puma_control    = "unix://#{shared_path}/sockets/pumactl.sock"
puma_state      = "#{shared_path}/sockets/puma.state"

directory '/home/tryredis/try.redis/current'
rackup 'config.ru'
environment stage
daemonize false
pidfile puma_pid
state_path puma_state

threads 2, 4

bind puma_sock
activate_control_app puma_control
