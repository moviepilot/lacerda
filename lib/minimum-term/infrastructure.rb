require 'active_support/core_ext/hash/indifferent_access'

module MinimumTerm
  class Infrastructure
    attr_reader :errors, :data_dir

    def initialize(data_dir:, verbose: false)
      @verbose = !!verbose
      @data_dir = data_dir
      @mutex1 = Mutex.new
      @mutex2 = Mutex.new
    end

    def reload
      @services = nil
    end

    def contracts_fulfilled?
      @mutex1.synchronize do
        @errors = {}
        publishers.each do |publisher|
          publisher.satisfies_consumers?(verbose: @verbose)
          next if publisher.errors.empty?
          @errors.merge! publisher.errors
        end
        @errors.empty?
      end
    end

    def publishers
      services.values.select do |service|
        service.published_objects.length > 0
      end
    end

    def consumers
      services.values.select do |service|
        service.consumed_objects.length > 0
      end
    end

    def convert_all!(keep_intermediary_files = false)
      json_files.each{ |file| FileUtils.rm_f(file) }
      mson_files.each do |file|
        MinimumTerm::Conversion.mson_to_json_schema!(
          filename: file,
          keep_intermediary_files: keep_intermediary_files,
          verbose: @verbose)
      end
      reload
    end

    def mson_files
      Dir.glob(File.join(@data_dir, "/**/*.mson"))
    end

    def json_files
      Dir.glob(File.join(@data_dir, "/**/*.schema.json"))
    end

    def services
      @mutex2.synchronize do
        return @services if @services
        @services = {}.with_indifferent_access
        dirs = Dir.glob(File.join(@data_dir, "*/"))
        dirs.each do |dir|
          service = MinimumTerm::Service.new(self, dir)
          @services[service.name] = service
        end
        @services
      end
    end
  end
end
