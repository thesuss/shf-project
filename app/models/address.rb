class Address < ApplicationRecord

  belongs_to :addressable, polymorphic: true

  belongs_to :region

  belongs_to :kommun


  validates_presence_of :addressable

  validates_presence_of :country


  scope :has_region, -> { where('region_id IS NOT NULL') }

  scope :lacking_region, -> { where('region_id IS NULL') }


  geocoded_by :entire_address

  after_validation :geocode_best_possible,
                   :if => lambda { |obj| obj.changed? }


  # geocode all of the addresses that need it
  #
  # sleep_between = number of seconds to sleep between each geocode call so
  #  that we don't go over the # requests per second of the service (ex Google)
  # num_per_batch = the number to fetch from the db per batch
  #
  def self.geocode_all_needed(sleep_between: 0.5, num_per_batch: 50)

    need_geocoding = self.not_geocoded # this method comes from Geocoder

    Geocoder.configure(timeout: 20) # geocoding service timeout (secs).
    # need this long to ensure we don't timeout

    need_geocoding.find_each(batch_size: num_per_batch) do |addr|
      addr.geocode_best_possible
      addr.save
      sleep(sleep_between.to_f)
    end
    
  end


  def entire_address
    [street_address, city, post_code, sverige_if_nil].compact.join(', ')
  end


  # Geocode the address, starting with all of the data.
  #  If we don't get a geocoded result, then keep trying,
  #  using less and less 'specific' address information
  #  until we can get a latitude, longitude returned from geocoding.
  # This will handle addresses that aren't correct (ex: generated with FFaker or possibly entered wrong)
  # and so will guarantee that at least *some* map can be displayed.  (Important for a company!)
  def geocode_best_possible

    specificity_order = [street_address, post_code, city, sverige_if_nil]

    most_specific = 0
    least_specific = specificity_order.size - 1

    geo_result = nil

    until most_specific > least_specific || geo_result.present?
      geocode_address = specificity_order[most_specific..least_specific].compact.join(', ')
      geo_result = Geocoder.coordinates(geocode_address)
      most_specific += 1
    end

    unless geo_result.nil?
      self.latitude = geo_result.first
      self.longitude = geo_result.last
    end

  end


  private


  def sverige_if_nil
    country = 'Sverige' if country.nil?
    country
  end

end