set :stage, 'production'
set :shared_children, shared_children << 'tmp/sockets'

puma_state   = "#{shared_path}/sockets/puma.state"

namespace :deploy do
  desc "Start the application"
  task :start do
    run "cd #{current_path} && RACK_ENV=#{stage} bundle exec puma -C #{current_path}/config.rb", :pty => false
  end

  desc "Stop the application"
  task :stop do
    run "cd #{current_path} && RACK_ENV=#{stage} bundle exec pumactl -S #{puma_state} stop"
  end

  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    deploy.stop
    deploy.start
  end

  desc "Status of the application"
  task :status, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RACK_ENV=#{stage} bundle exec pumactl -S #{puma_state} stats"
  end
end
