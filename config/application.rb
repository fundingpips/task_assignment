# frozen_string_literal: true

require_relative "boot"

# Only require the parts of Rails we need
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_storage/engine"

Bundler.require(*Rails.groups)

module IpActivities
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
  end
end
