namespace :config do
  task :setup do
   ask(:db_user, 'db_user')
   ask(:db_pass, 'db_pass')
   ask(:db_name, 'db_name')
   ask(:db_host, 'db_host')
setup_config = <<-EOF
#{fetch(:rails_env)}:
adapter: postgresql
database: #{fetch(:db_name)}
username: #{fetch(:db_user)}
password: #{fetch(:db_pass)}
host: #{fetch(:db_host)}
EOF
  on roles(:app) do
     execute "mkdir -p #{shared_path}/config"
     upload! StringIO.new(setup_config), "#{shared_path}/config/database.yml"
    end
  end
end

namespace :config do
  task :setup do
    ask(:SECRET_KEY_BASE, 'SECRET_KEY_BASE')
    ask(:AWS_ACCESS_KEY_ID, 'AWS_ACCESS_KEY_ID')
    ask(:AWS_SECRET_ACCESS_KEY, 'AWS_SECRET_ACCESS_KEY')
env_config = <<-EOF
SECRET_KEY_BASE=#{fetch(:SECRET_KEY_BASE)}
AWS_ACCESS_KEY_ID=#{fetch(:AWS_ACCESS_KEY_ID)}
AWS_SECRET_ACCESS_KEY=#{fetch(:AWS_SECRET_ACCESS_KEY)}
EOF
    on roles(:app) do
      execute "mkdir -p #{shared_path}"
      upload! StringIO.new(env_config), "#{shared_path}/.env"
    end
  end
end


