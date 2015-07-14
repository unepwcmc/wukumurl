set :rails_env, "staging"
set :branch, "private_links"

set :domain, "unepwcmc-011.vm.brightbox.net"
server "unepwcmc-011.vm.brightbox.net", :app, :web, :db, :primary => true
set :application, "wukumurl"
set :server_name, "wukumurl.unepwcmc-011.vm.brightbox.net"
set :sudo_user, "rails"
set :app_port, "80"
