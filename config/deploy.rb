require 'rvm/capistrano'                  # Load RVM's capistrano plugin.
require 'bundler/capistrano'

set :application, "ryanromanchuk"
set :rails_env, 'production'

set :rvm_ruby_string, '2.0.0' # Or whatever env you want it to run in.

role :web, "linksie.com"
role :db,  "linksie.com", :primary => true # This is where Rails migrations will run

# server details
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/home/ubuntu/ryanromanchuk"
set :deploy_via, :remote_cache
set :user, "ubuntu"
set :use_sudo, false
ssh_options[:forward_agent] = true

# repo details
set :scm, :git
set :repository,  "git@github.com:/rromanchuk/ryanromanchuk.git"
set :branch, "master"


after 'deploy:update', 'deploy:cleanup'
before 'deploy:symlink', 'deploy:abort_if_pending_migrations'
before 'deploy:symlink', 'deploy:avatar_symlink'
after 'deploy:update_code' do
  run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
end

# tasks
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :web, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end
  task :abort_if_pending_migrations, :roles => :db, :only => { :primary => true } do
    run "cd #{release_path} && bundle exec rake RAILS_ENV=#{rails_env} db:abort_if_pending_migrations"
  end
  task :nginx, :roles => :web do
    run 'sudo /etc/init.d/nginx restart'
  end
end