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
#
# methods to convert to json_ld are taken from the schema_dot_org gem
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file Thing
#
#--------------------------

module SchemaDotOrg

  class Thing < AbstractJsonLd

    include ActiveModel::Validations

    attr_accessor :name, :description, :url

    validates_presence_of :name


    def _to_json_struct
      { 'name' => name,
        'description' => description,
        'url' => url
      }
    end

  end

end
