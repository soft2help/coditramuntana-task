RSpec.shared_context "with clean redis", shared_context: :metadata do
  after(:each) do
    redis_namespace = Rails.cache.options[:namespace]
    get_redis.keys("#{redis_namespace}*").each { |k| get_redis.del(k) }
  end
end
