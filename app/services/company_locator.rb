# frozen_string_literal: true


#--------------------------
#
# @class CompanyLocator
#
# @desc Responsibility: Find a Company near some location
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   11/8/18
#
# @file company_locator.rb
#
#--------------------------


class CompanyLocator

  DEFAULT_COUNTRY = 'Sverige'

  DEFAULT_DISTANCE = 10


  # Find all companies with 'distance_km' kilometers of the latitude and longitude
  #
  # return a collection of companies found or an empty collection if none found
  def self.find_near_coordinates(latitude, longitude, distance_km = DEFAULT_DISTANCE)
    raise ArgumentError, I18n.t('company_locator.error.latitude_blank') if latitude.blank?
    raise ArgumentError, I18n.t('company_locator.error.longitude_blank') if longitude.blank?

    distance = self.fix_nil_distance(distance_km)
    raise ArgumentError, I18n.t('company_locator.error.search_distance_negative') if distance < 0

    # Need to return this as an array because the query Geocoder uses for .near
    # _cannot_ handle a .order  or .count  or other ActiveRecord method after it.
    Address.company_address.near([latitude, longitude], distance, unit: :km, order: 'distance').to_a

  end


  # Find all companies with 'distance_km' kilometers
  # near a location named 'location_name' in the country named 'country'
  #
  # return a collection of companies found or an empty collection if none found
  def self.find_near_name(location_name, distance_km = DEFAULT_DISTANCE, country: DEFAULT_COUNTRY)

    sanitized_location = InputSanitizer.sanitize_string(location_name)
    raise ArgumentError, I18n.t('company_locator.error.search_name_blank') if sanitized_location.blank?

    distance = self.fix_nil_distance(distance_km)
    raise ArgumentError, I18n.t('company_locator.error.search_distance_negative') if distance < 0

    country_fixed = country.nil? ? DEFAULT_COUNTRY : country

    # Need to return this as an array because the query Geocoder uses for .near
    # _cannot_ handle a .order  or .count  or other ActiveRecord method after it.
    Address.company_address.near( "#{sanitized_location}, #{country_fixed}", distance, unit: :km, order: 'distance').to_a

  end


  def self.fix_nil_distance(possibly_nil_distance)
    possibly_nil_distance.nil? ?  DEFAULT_DISTANCE : possibly_nil_distance
  end

end # CompanyLocator

