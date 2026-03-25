# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "bundler/setup"
require "minitest/autorun"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "active_record"
require "pagy"

# Dummy Rails app for testing
class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.eager_load = false
  config.secret_key_base = "secret"
  
  # Disable deprecation warnings
  config.active_support.deprecation = :silence
end

TestApp.initialize!

# Setup database
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

# Create SolidCache tables
ActiveRecord::Schema.define do
  create_table :solid_cache_entries do |t|
    t.binary :key, null: false
    t.binary :value, null: false
    t.integer :key_hash, null: false, limit: 8
    t.integer :byte_size, null: false
    t.timestamps
    t.index :key_hash, unique: true
    t.index [:byte_size, :key_hash]
    t.index :created_at
  end

  create_table :solid_cache_dashboard_events do |t|
    t.string :event_type, null: false
    t.integer :count, null: false, default: 1
    t.datetime :created_at, null: false
    t.index :event_type
    t.index :created_at
  end
end

# Define SolidCache models
module SolidCache
  class Entry < ActiveRecord::Base
    self.table_name = "solid_cache_entries"
    
    def self.find_by_key_hash(key_hash)
      find_by(key_hash: key_hash)
    end
  end
end

# Load the gem
require "solid_cache_dashboard"

# Include Pagy modules in controllers before loading engine code
if SolidCacheDashboard.pagy_43_or_newer?
  ActionController::Base.include Pagy::Method
else
  ActionController::Base.include Pagy::Backend
end

# Ensure engine code is loaded for testing
require_relative "../app/helpers/solid_cache_dashboard/application_helper"
require_relative "../app/controllers/solid_cache_dashboard/application_controller"

# Register the engine's view paths so partials can be found
engine_views = File.expand_path("../app/views", __dir__)
ActionController::Base.prepend_view_path(engine_views)


# Test helpers
class ActiveSupport::TestCase
  def assert_pagy_compatibility
    if SolidCacheDashboard.pagy_43_or_newer?
      assert Gem::Version.new(Pagy::VERSION) >= Gem::Version.new("43.0.0")
    else
      assert Gem::Version.new(Pagy::VERSION) < Gem::Version.new("43.0.0")
    end
  end
end