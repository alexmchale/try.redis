load 'deploy' if respond_to?(:namespace) # cap2 differentiator

default_run_options[:pty] = true

# be sure to change these
set :user, 'alexmchale'
set :domain, 'redis-db.com'
set :application, 'try.redis'

# the rest should be good
set :repository,  "#{user}@#{domain}:~#{user}/src/#{application}"
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache
set :scm, 'git'
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true
set :use_sudo, true

server domain, :app, :web

namespace :deploy do
  task :restart do
    run "/etc/init.d/apache2 restart"
  end
end

