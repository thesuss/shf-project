#!/usr/bin/ruby


#--------------------------
#
# @class Adapter::CompanyToSchemaOrganization
#
# @desc Responsibility: (an Adapter) takes a Company and creates a
#   schema.org organization
#     Pattern: Adapter
#       Adaptee: Company
#       Target: schema.org Organization  https://schema.org/Organization
#
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file company_to_schema_org_adapter.rb
#
#--------------------------

module Adapter

  class CompanyToSchemaOrganization < AbstractSchemaOrgAdapter


    def target_class
      SchemaDotOrg::Organization
    end


    def set_target_attributes(target)

      target.name        = @adaptee.name
      target.description = @adaptee.description
      target.url         = @adaptee.website
      target.email       = @adaptee.email
      target.telephone   = @adaptee.phone_number

      target.location = AddressToSchemaPlace.new(@adaptee.addresses.first).as_target

      # TODO: image, (how to do multiple?)
      # TODO: logo

      target
    end

  end

end

