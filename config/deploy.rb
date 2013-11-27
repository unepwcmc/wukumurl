set :default_stage, 'staging'
require 'capistrano/ext/multistage'

require 'brightbox/recipes'
require 'brightbox/passenger'

load "deploy/assets"
set :rake, 'bundle exec rake'

require 'rvm/capistrano'
set :rvm_ruby_string, '2.0.0'

set :generate_webserver_config, false

ssh_options[:forward_agent] = true

#set :whenever_command, "bundle exec whenever"
#require "whenever/capistrano"
# so unfortunately the whenever task is fired before bundling takes place
# because of this commit: https://github.com/javan/whenever/commit/7ae1009c31deb03c5db4a68f5fc99ea099ce5655

# The name of your application.  Used for deployment directory and filenames
# and Apache configs. Should be unique on the Brightbox
set :application, "wukumurl"

# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, application) }

# URL of your source repository. By default this will just upload
# the local directory.  You should probably change this if you use
# another repository, like git or subversion.

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
set :local_shared_files, %w(config/database.yml config/max_mind.yml config/cartodb_config.yml)

# Forces a Pty so that svn+ssh repository access will work. You
# don't need this if you are using a different SCM system. Note that
# ptys stop shell startup scripts from running.
default_run_options[:pty] = true

task :setup_production_database_configuration do
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
after "deploy:setup", :setup_production_database_configuration

# run like: cap staging rake_invoke task=a_certain_task
task :rake_invoke do
  run("cd #{deploy_to}/current; bundle exec /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")
end
