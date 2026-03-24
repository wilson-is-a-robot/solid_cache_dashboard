module SolidCacheDashboard
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    helper SolidCacheDashboard::ApplicationHelper

    def dark_mode?
      cookies[:solid_cache_dashboard_dark_mode] == "true"
    end
    helper_method :dark_mode?

    private

    # Pagy compatibility wrapper for both v43+ and v6-8.x
    def pagy(collection, **options)
      if defined?(Pagy::Method) && method(:pagy).owner == Pagy::Method
        # Pagy 43+: pagy(:offset, collection, limit: N)
        limit = options.delete(:items) || options.delete(:limit) || 25
        super(:offset, collection, **options.merge(limit: limit))
      else
        # Pagy 6-8.x: pagy(collection, items: N)
        items = options.delete(:limit) || options.delete(:items) || 25
        super(collection, **options.merge(items: items))
      end
    end
  end
end
