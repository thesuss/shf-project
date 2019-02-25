#!/usr/bin/ruby

require_relative File.join(__dir__, '../concerns/company_hmarkt_url_generator')

#--------------------------
#
# @class Adapters::CompanyToSchemaLocalBusiness
#
# @desc Responsibility: (an Adapter) takes a Company and creates a
#   schema.org local business
#   Note that we need to create a local business so that we can have multiple
#   locations (places).
#
#     Pattern: Adapter
#       @adaptee: Company
#       target: SchemaDotOrg::LocalBusiness  https://schema.org/LocalBusiness
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file company_to_schema_local_business.rb
#
#--------------------------

module Adapters

  class CompanyToSchemaLocalBusiness < AbstractSchemaOrgAdapter

    include CompanyHMarktUrlGenerator


    def target_class
      SchemaDotOrg::LocalBusiness
    end


    def set_target_attributes(target)

      target.name        = @adaptee.name
      target.description = @adaptee.description
      target.url         = @adaptee.website
      target.email       = @adaptee.email
      target.telephone   = @adaptee.phone_number
      target.image       = company_h_markt_url(@adaptee)

      # this may set many properties, so we work with the target
      target = set_address_properties(target, @adaptee)

      target.knowsLanguage = 'sv-SE'

      # this just sets 1 property
      target.knowsAbout = set_knows_about(@adaptee)

      target
    end



    def url_for_co_hbrand_image(company)
      "#{I18n.t('shf_medlemssystem_url')}/hundforetag/#{company.id}/company_h_brand"
    end


    # ==========================================================================
    # ==========================================================================


    private


    def set_address_properties(target, adaptee)
      unless adaptee.addresses.empty?
        target.address = AddressToSchemaPostalAddress.new(adaptee.addresses.first).as_target
        target.geo     = AddressToSchemaGeoCoordinates.new(adaptee.addresses.first).as_target

        # for multiple addresses, list multiple locations, each with an address and geo coordinates
        if adaptee.addresses.size > 1

          target.location = []
          adaptee.addresses.each do |address|
            target.location << AddressToSchemaPlace.new(address).as_target
          end
        end

      end

      target
    end


    # set the "knowsAbout" property to the list of business categories for the company
    def set_knows_about(adaptee)

      return nil if adaptee.business_categories.empty?

      knows_about = []
      adaptee.business_categories.each do |category|
        knows_about << "#{I18n.t('dog').capitalize} #{category.name}"
      end

      knows_about
    end
  end

end

