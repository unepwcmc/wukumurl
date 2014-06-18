set :rails_env, "production"
set :domain, "unepwcmc-014.vm.brightbox.net"

server "unepwcmc-014.vm.brightbox.net", :app, :web, :db, :primary => true

set :application, "wukumurl"
set :server_name, "wukumurl.unepwcmc-014.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80"

#set :whenever_environment, defer { stage }
#require "whenever/capistrano"
