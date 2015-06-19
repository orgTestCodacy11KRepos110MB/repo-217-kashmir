require "kashmir/version"
require "kashmir/representation"
require "kashmir/dsl"
require "kashmir/inline_dsl"
require "kashmir/plugins/ar"
require "kashmir/caching"
require "kashmir/representable"

module Kashmir

  class << self

    attr_accessor :logger

    def included(klass)
      klass.extend Representable::ClassMethods
      klass.include Representable

      if klass.ancestors.include?(::ActiveRecord::Base)
        klass.include Kashmir::AR
      end
    end

    def init(options={})
      if client = options[:cache_client]
        @caching = client
      end

      if logger = options[:logger]
        @logger = logger
      end
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end

    def caching
      @caching ||= Kashmir::Caching::Null.new
    end
  end
end
