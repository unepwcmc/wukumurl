set :default_stage, 'staging'
require 'capistrano/ext/multistage'

require 'brightbox/recipes'
require 'brightbox/passenger'

set :rake, 'bundle exec rake'

set :generate_webserver_config, false

ssh_options[:forward_agent] = true

set :rvm_ruby_string, '2.0.0'

# Load RVM's capistrano plugin.
require 'rvm/capistrano'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"
# so unfortunately the whenever task is fired before bundling takes place
# because of this commit: https://github.com/javan/whenever/commit/7ae1009c31deb03c5db4a68f5fc99ea099ce5655

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "wukumurl"

# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, application) }

set :repository,  "git@github.com:unepwcmc/wukumurl.git"
set :scm, :git
set :scm_username, "unepwcmc-read"
set :deploy_via, :remote_cache

## Local Shared Area
# These are the list of files and directories that you want
# to share between the releases of your application on a particular
# server. It uses the same shared area as the log files.
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :local_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :local_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
set :local_shared_files, %w(config/database.yml config/max_mind.yml config/cartodb_config.yml config/environments/production.rb)

# Forces a Pty so that svn+ssh repository access will work. You
# don't need this if you are using a different SCM system. Note that
# ptys stop shell startup scripts from running.
default_run_options[:pty] = true

namespace :config do
  task :cartodb do
    the_host = Capistrano::CLI.ui.ask("CartoDB Host:")
    oauth_key = Capistrano::CLI.ui.ask("CartoDB OAuth Key:")
    oauth_secret = Capistrano::CLI.ui.ask("CartoDB OAuth Secret:")
    username = Capistrano::CLI.ui.ask("CartoDB Username:")
    password = Capistrano::CLI.ui.ask("CartoDB Password:")
    api_key = Capistrano::CLI.ui.ask("CartoDB API Key:")

    require 'yaml'

    spec = {
      host: the_host,
      oauth_key: oauth_key,
      oauth_secret: oauth_secret,
      username: username,
      password: password,
      api_key: api_key
    }

    run "mkdir -p #{shared_path}/config"
    put(spec.to_yaml, "#{shared_path}/config/cartodb_config.yml")
  end
end
after "db:setup", 'config:cartodb'

namespace :db do
  task :setup do
    the_host = Capistrano::CLI.ui.ask("Database IP address: ")
    database_name = Capistrano::CLI.ui.ask("Database name: ")
    database_user = Capistrano::CLI.ui.ask("Database username: ")
    pg_password = Capistrano::CLI.password_prompt("Database user password: ")

    require 'yaml'

    spec = {
      "#{rails_env}" => {
        "adapter" => "postgresql",
        "database" => database_name,
        "username" => database_user,
        "host" => the_host,
        "password" => pg_password
      }
    }

    run "mkdir -p #{shared_path}/config"
    put(spec.to_yaml, "#{shared_path}/config/database.yml")
  end
end
after "deploy:setup", 'db:setup'

namespace :deploy do
  desc "Tell Passenger to restart the app."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

desc "Configure VHost"
task :config_vhost do
  vhost_config = <<-EOF
    server {
      server_name #{server_name};
      listen 80;

      client_max_body_size 4G;
      gzip on;
      keepalive_timeout 5;
      root #{deploy_to}/public;

      passenger_enabled on;
      rails_env #{rails_env};

      add_header 'Access-Control-Allow-Origin' *;
      add_header 'Access-Control-Allow-Methods' "GET, POST, PUT, DELETE, OPTIONS";
      add_header 'Access-Control-Allow-Headers' "X-Requested-With, X-Prototype-Version";
      add_header 'Access-Control-Max-Age' 1728000;

      location ^~ /assets/ {
        expires max;
        add_header Cache-Control public;
      }

      if (-f $document_root/system/maintenance.html) {
        return 503;
      }

      error_page 500 502 504 /500.html;
      location = /500.html {
        root #{deploy_to}/public;
      }

      error_page 503 @maintenance;
      location @maintenance {
        rewrite  ^(.*)$  /system/maintenance.html break;
      }
    }
  EOF

  put vhost_config, "/tmp/vhost_config"
  sudo "mv /tmp/vhost_config /etc/nginx/sites-available/#{application}"
  sudo "ln -s /etc/nginx/sites-available/#{application} /etc/nginx/sites-enabled/#{application}"
end
after "deploy:setup", :config_vhost

# run like: cap staging rake_invoke task=a_certain_task
task :rake_invoke do
  run("cd #{deploy_to}/current; bundle exec /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")
end
