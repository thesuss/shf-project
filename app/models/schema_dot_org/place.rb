#!/usr/bin/ruby

#--------------------------
#
# @class Place
#         https://schema.org/Place
#   This is just a subset of the properties of the schema.org Place type
#
# @desc Responsibility: "Entities that have a somewhat fixed, physical extension."
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file place.rb
#
#--------------------------

module SchemaDotOrg

  class Place < Thing

    # address is a PostalAddress, geo is a GeoCoordinates
    attr_accessor :address,
                  :geo


    def _to_json_struct
      as_json
    end

  end

end
