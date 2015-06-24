require 'dalli'

module Kashmir
  module Caching
    class Memcached

      attr_reader :client

      def initialize(client, default_ttl = 3600)
        @client = client
        @default_ttl = default_ttl
      end

      def from_cache(definitions, instance)
        key = presenter_key(definitions, instance)
        if cached_data = get(key)
          return cached_data
        end
      end

      def bulk_from_cache(definitions, instances)
        keys = instances.map do |instance|
          presenter_key(definitions, instance) if instance.respond_to?(:id)
        end.compact

        client.get_multi(keys).values.map do |value|
          JSON.parse(value, symbolize_names: true)
        end
      end

      def bulk_write(definitions, representations, instances, ttl)
        client.multi do
          instances.each_with_index do |instance, index|
            key = presenter_key(definitions, instance)
            set(key, representations[index], ttl)
          end
        end
      end

      def store_presenter(definitions, representation, instance, ttl=0)
        key = presenter_key(definitions, instance)
        set(key, representation, ttl)
      end

      def presenter_key(definition_name, instance)
        "#{instance.class}:#{instance.id}:#{definition_name}"
      end

      def get(key)
        if data = client.get(key)
          JSON.parse(data, symbolize_names: true)
        end
      end

      def set(key, value, ttl=nil)
        client.set(key, value.to_json, ttl || @default_ttl)
      end

      def clear(definition, instance)
        key = presenter_key(definition, instance)
        client.delete(key)
      end
    end
  end
end
