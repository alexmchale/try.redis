#!/usr/bin/env puma

stage           = ENV['RACK_ENV']
shared_path     = '/home/tryredis/try.redis/shared'
puma_pid        = "#{shared_path}/pids/puma.pid"
puma_sock       = "unix://#{shared_path}/sockets/puma.sock"
puma_control    = "unix://#{shared_path}/sockets/pumactl.sock"
puma_state      = "#{shared_path}/sockets/puma.state"
puma_log_stdout = "#{shared_path}/log/puma-#{stage}-stdout.log"
puma_log_stderr = "#{shared_path}/log/puma-#{stage}-stderr.log"

directory '/home/tryredis/try.redis/current'
rackup 'config.ru'
environment stage
daemonize true
pidfile puma_pid
state_path puma_state
stdout_redirect puma_log_stdout, puma_log_stderr

threads 2, 4

bind puma_sock
activate_control_app puma_control
