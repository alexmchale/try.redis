load 'deploy' if respond_to?(:namespace) # cap2 differentiator

default_run_options[:pty] = true

# be sure to change these
set :user, 'alexmchale'
set :domain, 'redis-db.com'
set :application, 'try.redis'

# the rest should be good
set :repository,  "git://github.com/alexmchale/try.redis.git"
set :deploy_to, "/var/www/#{application}"
set :scm, 'git'
set :branch, 'master'
set :scm_verbose, true
set :use_sudo, true

server domain, :app, :web

namespace :deploy do
  task :restart do
    run "sudo /etc/init.d/apache2 restart"
  end
end

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end

  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without development test"
  end
end

after 'deploy:update_code', 'bundler:bundle_new_release'
