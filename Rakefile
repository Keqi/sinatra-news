require 'active_record'
require 'dotenv'
require 'rspec/core/rake_task'

require_relative 'lib/models/user'
require_relative 'lib/models/vote'
require_relative 'lib/models/story'
require_relative 'lib/models/board'

task default: :spec

RSpec::Core::RakeTask.new(:spec) do |task|
  task.verbose = false
end

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

  task seed: :configure_connection do
    User.delete_all
    Board.delete_all
    Story.delete_all
    Vote.delete_all

    maciorn = User.create!(username: 'maciorn', password: 'secret')
    jacek   = User.create!(username: 'jacek', password: 'secret')

    board = Board.create!(title: "Famous sites")

    gag   = Story.create!(user: maciorn, title: '9gag', url: "http://www.9gag.com")
    kwejk = Story.create!(user: maciorn, title: 'kwejk', url: "http://www.kwejk.pl")
    onet  = Story.create!(user: jacek, title: 'onet', url: "http://www.onet.pl")

    Vote.create!(story: gag, user: maciorn, value: 1)
    Vote.create!(story: gag, user: jacek, value: 1)
    Vote.create!(story: kwejk, user: maciorn, value: 1)
    Vote.create!(story: onet, user: maciorn, value: -1)
    Vote.create!(story: onet, user: jacek, value: -1)
  end

  desc 'Configure connection'
  task configure_connection: :environment do
    ActiveRecord::Base.establish_connection ENV['DATABASE_URL']
  end

  task :environment do
    ENV["ENV"] == "test" ? Dotenv.load(".env.test") : Dotenv.load
  end
end