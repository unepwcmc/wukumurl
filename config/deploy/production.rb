set :rails_env, "production"
set :domain, "unepwcmc-014.vm.brightbox.net"

server "unepwcmc-014.vm.brightbox.net", :app, :web, :db, :primary => true

set :application, "unepio"
set :server_name, "unepio.unepwcmc-014.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80"
