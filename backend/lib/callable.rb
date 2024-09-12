module Callable
  extend ActiveSupport::Concern

  included do
    def call
      raise NotImplementedError
    end
  end

  module ClassMethods
    # rubocop:disable Style/ArgumentsForwarding
    def call(*args)
      new(*args).call
    end
    # rubocop:enable Style/ArgumentsForwarding
  end
end
