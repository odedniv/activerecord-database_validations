require "bundler/gem_tasks"

namespace :db do
  desc "Prepare databases for testing"
  task :prepare do
    require "active_record"
    require File.expand_path("../spec/db/adapters.rb", __FILE__)
    DATABASE_ADAPTERS.each do |database_adapter_config|
      ActiveRecord::Base.establish_connection(database_adapter_config)
      load File.expand_path("../spec/db/schema.rb", __FILE__)
    end
  end
end
