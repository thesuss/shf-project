#!/usr/bin/ruby

#--------------------------
#
# @class Thing - the topmost class in the schema.org hierarchy
#         https://schema.org/Thing
#   This is just a subset of the properties of the schema.org Thing type
#
# @desc Responsibility: "The most generic type of item."
#
#     Properties implemented:
#       name	      Text 	The name of the item.
#       description	Text 	A description of the item.
#       url	        URL 	URL of the item.
#
# methods to convert to json_ld are taken from the schema_dot_org gem
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file thing.rb
#
#--------------------------

module SchemaDotOrg

  class Thing #< AsJsonLd

    include ActiveModel::Validations
    include ToLdJson

    attr_accessor :name, :description, :url

    validates_presence_of :name


    # recurse down through structures to get the JSON or :to_json_struct value
    # of every item.
    #
    # If an item responds to :to_json_struct, use that instead of :as_json (because
    # that means it is a schema.org object).
    #
    # @return [Hash] - a ld+json representation, including the @type of the object
    #   as the first element in the Hash
    #
    def _to_json_struct
      json_struct_method = :to_json_struct
      struct             = {}

      instance_variables.each do |attrib|
        attrib_name  = attrib.to_s[1..-1] # instance_variable name without the '@'
        attrib_value = instance_variable_get(attrib)

        if attrib_value.respond_to?(:each)
          struct[attrib_name] = list_to_json_struct(attrib_value, json_struct_method)
        else
          struct[attrib_name] = value_via_method_or_as_json(attrib_value, json_struct_method)
        end
      end

      { "@type" => un_namespaced_classname }.merge(struct).compact
    end


    # ==========================================================================
    # ==========================================================================


    private


    # loop through the (enumerable) list to see if anything responds to
    # the json_struct_method.
    #
    # @return [Enumerable] - a list of values, where each value is either :as_json
    #    or the value from sending the json_struct_method to each item in the list
    def list_to_json_struct(list, json_struct_method)
      json_struct_list = []

      list.each do |item|
        json_struct_list << value_via_method_or_as_json(item, json_struct_method)
      end

      json_struct_list
    end


    # If the item responds to the json_method, send the json_method to get the value.
    # Else send :as_json to get the value
    def value_via_method_or_as_json(item, json_method)
      item.respond_to?(json_method) ? item.send(json_method) : item.as_json
    end

  end

end
