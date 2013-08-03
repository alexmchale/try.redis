namespace :deploy do
  desc "Start the application"
  task :start do
    run "#{sudo} systemctl start tryredis"
  end

  desc "Stop the application"
  task :stop do
    run "cd #{current_path} && RACK_ENV=#{stage} bundle exec pumactl -S #{puma_state} stop"
    run "#{sudo} systemctl stop tryredis", :pty => false
  end

  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{sudo} systemctl restart tryredis", :pty => false
  end

  desc "Status of the application"
  task :status, :roles => :app, :except => { :no_release => true } do
    run "systemctl status tryredis"
  end
end
