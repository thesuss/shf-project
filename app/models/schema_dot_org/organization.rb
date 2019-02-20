#!/usr/bin/ruby

#--------------------------
#
# @class Organization
#         https://schema.org/Organization
#   This is just a subset of the properties of the schema.org Organization type
#
# @desc Responsibility: "An organization such as a school, NGO, corporation, club, etc."
#
#     Only a small subset of schema.org properties are implemented
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file organization
#
#--------------------------

module SchemaDotOrg

  class Organization < Thing


    attr_accessor :email,
                  :telephone,
                  :location,
                  :image,
                  :memberOf,
                  :knowsLanguage


    def _to_json_struct
      as_json
    end

  end

end
