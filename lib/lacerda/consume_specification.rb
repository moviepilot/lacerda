require 'json'
require 'lacerda/specification'

module Lacerda
  class ConsumeSpecification < Lacerda::Specification

    # We will remove any properties from the schema that are not referencing
    # a published object from another service, but that are just local definitions
    # i.e.
    #
    #     {
    #       "type": "object",
    #       "definitions": {
    #         "message_properties": { ...},
    #         "service::message": {...}
    #         "
    #       }
    #       "properties": {
    #         "message_properties": { "$ref": "#/message_properties }, <- remove
    #         "service::message": { "$ref": "#/service::message" } <- keep
    #       }
    #     }
    #
    def initialize(service, schema_or_file)
      super
      return unless @schema['properties']
      @schema['properties'] = @schema['properties'].keep_if do |k, v|
        !!k.index(Lacerda::SCOPE_SEPARATOR)
      end
    end

    def object_description_class
      Lacerda::ConsumedObject
    end

    def scoped_schema(service)
      service_name_prefix = Lacerda.underscore(service.name + Lacerda::SCOPE_SEPARATOR)

      filtered_schema = Lacerda.deep_copy(schema)
      filtered_schema['properties'].select! do |k|
        Lacerda.underscore(k).start_with?(service_name_prefix)
      end
      filtered_schema
    end

    def object?(name)
      underscored_name = Lacerda.underscore(name)
      !!@schema[:definitions][underscored_name]
    end

    def object(name)
      underscored_name = Lacerda.underscore(name)
      schema_dup = Lacerda.deep_copy(@schema)

      # It's critical to delete this object from the definitions
      # or else the json validator gem will go into an endless loop
      object_schema = schema_dup['definitions'].delete underscored_name.to_s

      msg = "Unknown object type: #{underscored_name.to_s.to_json} not in #{schema['definitions'].keys.to_json} - did you specify it in consume.mson?"
      raise Lacerda::Service::InvalidObjectTypeError.new(msg) unless object_schema

      # Copy the definitions of our schema into the schema for the
      # object in case its properties include json pointers
      object_schema['definitions'] = schema_dup['definitions']

      Lacerda::ConsumedObject.new(service, name, object_schema)
    end
  end
end
