class ReportCacheControl
  def self.report_cache_key(page:, per_page:, order_field:)
    version = get_cache_version
    "report_v_#{version}_page_#{page}_per_page_#{per_page}_order_#{order_field}"
  end

  def self.cache_version_key
    "report_version"
  end

  def self.get_cache_version
    Rails.cache.fetch(cache_version_key) { Time.now.to_i }
  end

  def self.invalidate_cache_version
    Rails.cache.delete(cache_version_key)
  end
end
