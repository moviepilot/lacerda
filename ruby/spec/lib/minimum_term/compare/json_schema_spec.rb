require 'spec_helper'

describe MinimumTerm::Compare::JsonSchema do

  let(:schema_hash) { 
    {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "definitions" => {
        "tag" => {
          "type" => "object",
          "properties" => { "id" => { "type" => "number", "description" => "Foobar" } },
          "required" => [ "id" ],
        },
        "post" => {
          "type" => "object",
          "properties" => {
            "id" => { "type" => "number", "description" => "The unique identifier for a post" },
            "title" => { "type" => "string", "description" => "Title of the product" },
            "author" => { "type" => "number", "description" => "External user id of author" },
            "tags" => { "type" => "array","items" => [ { "$ref" => "#/definitions/tag" } ] }
          },
          "required" => [ "id", "title" ]
        }
      }
    }
  }

  let(:to_compare_schema_hash) {
    {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "definitions" => {
        "post" => {
          "type" => "object",
          "properties" => { "id" => { "type" => "number" }, "name" => { "type" => "string" } },
          "required" => [ "id", "name" ]
        }
      }
    }
  }

  let(:schema) { MinimumTerm::Compare::JsonSchema.new(schema_hash) }


  describe "#contains?" do
    

    context "Json Schema containing another Json Schema" do  
      context "contains all the definitions" do
        it "doesn't detect a difference" do
          expect(schema.contains?(to_compare_schema_hash)).to be_truthy
        end
      end

      context "containing all the definitions and the properties" do
        it "doesn't detect a difference" do
          to_compare_schema_hash['definitions']['post']['properties'].delete('name')

          expect(schema.contains?(to_compare_schema_hash)).to be_truthy
        end
      end
    end

    context "Json Schema NOT containing anoother Json Schema" do
      context "NOT contains all the definitions" do
        it "detects the difference" do
          to_compare_schema_hash['definitions']['user'] = {}

          expect(schema.contains?(to_compare_schema_hash)).to be_falsey
        end
      end

      context "containing all the definitions but NOT the properties" do
        it "detects the difference" do
          expect(schema.contains?(to_compare_schema_hash)).to be_falsey
        end
      end
    end
  end
end