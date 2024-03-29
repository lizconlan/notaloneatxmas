require 'rubygems'
require 'bundler'
Bundler.load
require 'active_record'
require 'twitter'
require './models/pin'

task :cron => :environment do
  if ENV['consumer_key']
    Twitter.configure do |config|
      config.consumer_key = ENV['consumer_key']
      config.consumer_secret = ENV['consumer_secret']
      config.oauth_token = ENV['oauth_token']
      config.oauth_token_secret = ENV['oauth_token_secret']
    end
  end
  
  results = Twitter.search('#notaloneatxmas', :rpp => 100)

  results.each do |result|
    #ignore retweets
    unless result.text =~ /RT /
      #hunt for something that looks like a postcode
      postcode = nil
      if result.text =~ /(?: |^)([A-Z]{1,2}\d{1,2}(?: \d[A-Z]{2})?)(?: |$)/
        postcode = $1
        #great, to the mapping API
        unless Pin.find_by_name_and_postcode(result.from_user, postcode)
          pin = Pin.new
          pin.name = result.from_user
          pin.postcode = postcode
          pin.message = result.text
          pin.tweet_id = result.id
          pin.save
        end
      end
    end
  end
end



task :environment do
  env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[env])
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

namespace :db do
  desc "Create the database defined in config/database.yml for the current RACK_ENV"
  task(:create => :environment) do
    env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
    config = YAML::load(File.open('config/database.yml'))[env]
    ActiveRecord::Base.establish_connection(config.merge('database' => nil))
    ActiveRecord::Base.connection.create_database(config['database'])
  end
  
  namespace :create do
    desc "Create all the local databases defined in config/database.yml"
    task(:all => :environment) do
      YAML::load(File.open('config/database.yml')).each_value do |config|
        next unless config['database']
        ActiveRecord::Base.establish_connection(config.merge('database' => nil))
        ActiveRecord::Base.connection.create_database(config['database'])
      end
    end
  end
  
  desc "Drops the database for the current RACK_ENV"
  task :drop => :environment do
    env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
    config = YAML::load(File.open('config/database.yml'))[env]
    ActiveRecord::Base.connection.drop_database config['database']
  end
  
  namespace :drop do
    desc "Drops all the local databases defined in config/database.yml"
    task(:all => :environment) do
      YAML::load(File.open('config/database.yml')).each_value do |config|
        next unless config['database']
        ActiveRecord::Base.connection.drop_database config['database']
      end
    end
  end
  
  desc "Migrate the database through scripts in db/migrate"
  task(:migrate => :environment) do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :migrate do
    desc 'Runs the "down" for a given migration VERSION'
    task(:down => :environment) do
      ActiveRecord::Migrator.down('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    desc 'Runs the "up" for a given migration VERSION'
    task(:up => :environment) do
      ActiveRecord::Migrator.up('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
    
    desc "Rollbacks the database one migration and re migrate up"
    task(:redo => :environment) do
      ActiveRecord::Migrator.rollback('db/migrate', 1 )
      ActiveRecord::Migrator.up('db/migrate', nil )
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end
  end
  
  namespace :schema do
    task :dump => :environment do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || "db/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
  end
end