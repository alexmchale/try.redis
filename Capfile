load 'deploy'
require 'bundler/capistrano'

default_run_options[:pty] = true

# be sure to change these
set :user, 'tryredis'
set :domain, 'rediger.net'
set :port, 222
set :application, 'try.redis'
set :scm, 'git'
set :repository,  'git://github.com/badboy/try.redis.git'

set :deploy_to, "/home/tryredis/#{application}"
set :deploy_via, :remote_cache
set :keep_releases, 3

set :branch, 'master'
set :use_sudo, false

server domain, :app, :web

load 'capistrano/puma'
