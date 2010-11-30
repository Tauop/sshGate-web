require 'active_record'
require 'yaml'

task :environment do
  ENV['RACK_ENV'] ||= 'development'
  config = YAML.load_file('sshgate.yml')
  ActiveRecord::Base.establish_connection(config['database'][ENV['RACK_ENV']])
end

namespace :db do
  desc 'Migrate the database'
  task(:migrate => :environment) do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end
