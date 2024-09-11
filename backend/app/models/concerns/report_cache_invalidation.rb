# app/models/concerns/cache_invalidation.rb
module ReportCacheInvalidation
  extend ActiveSupport::Concern

  included do
    # Invalidate cache after commit for create, update, and destroy actions
    after_commit :invalidate_report_cache
  end

  private

  def invalidate_report_cache
    ReportCacheControl.invalidate_cache_version
  end
end
