require 'lacerda/specification'

module Lacerda
  class PublishSpecification < Lacerda::Specification

    def initialize(service, schema_or_file)
      super
    end

    def errors
      return [] unless @comparator
      @comparator.errors
    end

    def satisfies?(consumer, reporter = nil)
      Lacerda.validate_reporter(reporter)
      @comparator = Compare::JsonSchema.new(@schema)
      result = @comparator.contains?(consumer.consume.scoped_schema(service), consumer.name)
      reporter.try(:consume_specification_errors,consumer, errors)
      reporter.try(:consume_specification_satisfied, consumer, result)
      result
    end

    def object?(name)
      scoped_name = scopify_name(name)
      !!@schema[:definitions][scoped_name]
    end

    def object(name, scoped: true)
      object_name = scoped ? scopify_name(name) : Lacerda.underscore(name.to_s)
      schema_dup = Lacerda.deep_copy(@schema)

      # It's critical to delete this object from the definitions
      # or else the json validator gem will go into an endless loop
      object_schema = schema_dup['definitions'].delete object_name.to_s

      unless object_schema
        msg = "Unknown object type: #{object_name.to_s.to_json} not in #{schema['definitions'].keys.to_json} - did you specify it in publish.mson?"
        raise Lacerda::Service::InvalidObjectTypeError.new(msg)
      end

      # Copy the definitions of our schema into the schema for the
      # object in case its properties include json pointers
      object_schema['definitions'] = schema_dup['definitions']

      Lacerda::PublishedObject.new(service, object_name, object_schema)
    end

    private

    def scopify_name(name)
      scoped_name = Lacerda.underscore(name.to_s)

      # Add our own prefix automatically if necessary
      return scoped_name if scoped_name.start_with?(Lacerda.underscore(service.name))
      [Lacerda.underscore(service.name), scoped_name].join(Lacerda::SCOPE_SEPARATOR)
    end

    def object_description_class
      Lacerda::PublishedObject
    end
  end
end
