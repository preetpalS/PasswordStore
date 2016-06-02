
module PasswordStore
  # Provides access to text resources in './res' folder
  module Res
    VALID_LOADING_STRATEGIES = [:eager_load, :eagerly_index_and_load_lazily, :lazy_load].freeze
    DEFAULT_LOADING_STRATEGY = VALID_LOADING_STRATEGIES[0]
    DEFAULT_LOAD_PATH = 'src/res'.freeze

    class MissingFileError < RuntimeError; end

    # Abstract base class for resource loaders
    class Base
      def initialize(settings)
        raise 'Do not instantiate this class directly' if self.class == Base
        @load_path = settings[:asset_load_path] || DEFAULT_LOAD_PATH
        @file_extension = settings[:file_extension] || (raise 'File extension required')
        @loading_strategy = settings[:asset_loading_strategy] || DEFAULT_LOADING_STRATEGY
        @asset_cache = {}
        raise "Invalid loading_stategy: #{@loading_strategy}" unless
          PasswordStore::Res::VALID_LOADING_STRATEGIES.include? @loading_strategy
        load
      end

      def index
        case @loading_strategy
        when :eager_load, :eagerly_index_and_load_lazily
          @index
        when :lazy_load
          available_resources
        end
      end

      def [](file_basename)
        if [:eager_load, :eagerly_index_and_load_lazily].include? @loading_stategy
          raise MissingFileError, "#{file_basename}.#{@file_extension}" unless
            @index.include? "#{file_basename}.#{@file_extension}"
        end

        case @loading_strategy
        when :eager_load
          @asset_cache[file_basename]
        when :eagerly_index_and_load_lazily, :lazy_load
          load_asset(file_basename)
        end
      end

      protected

      def load_asset(file_basename)
        # puts "Loading: #{@load_path}/#{file_basename}.#{@file_extension}"
        File.open("#{@load_path}/#{file_basename}.#{@file_extension}", &:read)
      end

      private

      # Note that :lazy_load strategy requires no work in this step
      def load
        case @loading_strategy
        when :eager_load
          load_index
          @index.map do |indexed_item_path|
            file_basename = File.basename(indexed_item_path, ".#{@file_extension}")
            @asset_cache[file_basename] = load_asset(file_basename)
          end
        when :eagerly_index_and_load_lazily
          load_index
        end
      end

      def load_index
        case @loading_strategy
        when :eager_load, :eagerly_index_and_load_lazily
          @index = available_resources
        end
      end

      def available_resources
        (Dir.entries @load_path).select { |f| f[/.#{@file_extension}$/] }
      end
    end

    # SQL resource loader
    class SQL < Base
      VALID_MISSING_RESOURCE_STRATEGIES = [:fail].freeze

      def initialize(settings)
        super settings.merge file_extension: 'sql'
      end
    end

    # Text resource loader
    class Text < Base
      def initialize(settings)
        super settings.merge file_extension: 'txt'
      end
    end
  end
end
