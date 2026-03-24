# frozen_string_literal: true

# Enable test coverage if running in CI or with COVERAGE env var
if ENV["CI"] || ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/test/"
    add_filter "/config/"
    
    add_group "Controllers", "app/controllers"
    add_group "Helpers", "app/helpers"
    add_group "Views", "app/views"
    add_group "Library", "lib"
  end
end

require_relative "test_helper"