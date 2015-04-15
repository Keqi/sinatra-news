require 'dotenv'
require 'active_record'
require 'rspec/core/rake_task'

namespace :db do
  desc 'Migrate the database.'
  task migrate: :configure_connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate 'db/migrate'
  end

  desc 'Rolls the schema back to the previous version (specify steps w/ STEP=n).'
  task rollback: :configure_connection do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Migrator.rollback 'db/migrate', step
  end

  desc 'Configure connection'
  task configure_connection: :environment do
    ActiveRecord::Base.establish_connection ENV['DATABASE_URL']
  end

  task :environment do
    Dotenv.load(".env")
  end
end