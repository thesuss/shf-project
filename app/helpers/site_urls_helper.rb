#--------------------------
#
# @class SiteUrlsHelper
#
# @desc Responsibility: Helpers for navigation (menus, etc.)
#           One place to define URLS, etc. that are used frequently

# - Methods that end with _url will return an URL that can be used.  It will have the
# "http://|https://" (or whatever) at the start and will be valid.
#
# - Methods that end with _part  return just the [String] part specific to that url
# You need to concat them together with something else (like :https and :shf_main_site_hom_part)
# to create a full URL
#
# The names of the methods are long. That makes them very clear, but
# there's likely to be some good ideas to shorten them a bit.
#
# Additional URLS and parts can be added as is helpful.
# This is just a start.
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   3/21/19
#
# @file site_urls_helper.rb
#
module SiteUrlsHelper

  SLASH = '/'
  HTTPS = 'https://'

  SHF_MAIN_SITE_HOME_URL_PART = 'sverigeshundforetagare.se'

  ASSOCIATION_URL_PART = 'broschyr/'
  ASSN_BROCHURE_URL_PART = 'broschyr/'
  ASSN_BOARD_URL_PART = 'styrelse/'
  ASSN_MEMBERSHIP_URL_PART = 'foretag/medlemsatagande/'
  ASSN_STATUES_URL_PART = 'stadgar/'
  ASSN_GLOSSARY_URL_PART = 'ordlista/'
  ASSN_HISTORY_URL_PART = 'historik/'

  FOR_COMPANIES_URL_PART = 'foretag/'
  ABOUT_US_FOR_COMPANIES_URL_PART = 'foretag/om-sveriges-hundforetagare/'
  BECOME_H_LICENSED_COMPANIES_URL_PART = 'foretag/bli-h-markt/'
  EDUCATIONAL_REQS_COMPANIES_URL_PART = 'foretag/medlemskriterier/'
  MEMEBERSHIP_COMMIT_COMPANIES_URL_PART = 'foretag/medlemsatagande/'
  MEMEBERSHIP_ETHICS_GUIDE_URL_PART = 'foretag/lima-guiden/'
  GDPR_COMPANIES_URL_PART = 'foretag/gdpr/'
  MEMEBERSHIP_TO_BECOME_DOG_CO_URL_PART = 'foretag/vill-du-bli-hundforetagare/'
  QUALITY_CONTROL_COMPANIES_URL_PART = 'foretag/kvalitetskontroll/'
  SIGN_UP_FOR_COMPANIES_URL_PART = 'foretag/bli-medlem/'

  FOR_DOG_OWNERS_URL_PART = 'agare/'
  ABOUT_US_FOR_DOG_OWNERS_URL_PART = 'agare/om-sveriges-hundforetagare/'
  H_BRAND_DOG_OWNERS_URL_PART = 'agare/h-markt-av-sveriges-hundforetagare/'
  CONSUMER_CONTACT_FOR_DOG_OWNERS_URL_PART = 'agare/konsumentkontakt/'
  BECOME_SUPPORT_MEMBER_DOG_OWNERS_URL_PART = 'agare/bli-stodmedlem/'
  BEING_A_DOG_OWNER_DOG_OWNERS_URL_PART = 'agare/att-vara-hundagare/'

  CONTACT_URL_PART = 'kontakt'

  # ============================================================================================

  def https_shf_main_site_home_url
    make_https_url([SHF_MAIN_SITE_HOME_URL_PART])
  end


  def https_shf_main_site_contact_url
    main_site_url_with(CONTACT_URL_PART)
  end


  def https_shf_main_site_association_url
    main_site_url_with(ASSOCIATION_URL_PART)
  end


  def https_shf_main_site_assn_brochure_url
    main_site_url_with(ASSN_BROCHURE_URL_PART)
  end


  def https_shf_main_assn_site_board_url
    main_site_url_with(ASSN_BOARD_URL_PART)
  end

  def https_shf_main_site_assn_membership_url
    main_site_url_with(ASSN_MEMBERSHIP_URL_PART)
  end


  def https_shf_main_site_assn_statues_url
    main_site_url_with(ASSN_STATUES_URL_PART)
  end


  def https_shf_main_site_assn_glossary_url
    main_site_url_with(ASSN_GLOSSARY_URL_PART)
  end


  def https_shf_main_site_assn_history_url
    main_site_url_with(ASSN_HISTORY_URL_PART)
  end

  # ----------------
  # For Dog Owners
  #

  def https_shf_main_site_for_dog_owners_url
    main_site_url_with(FOR_DOG_OWNERS_URL_PART)
  end


  def https_shf_main_site_dog_owners_about_us_url
    main_site_url_with(ABOUT_US_FOR_DOG_OWNERS_URL_PART)
  end


  def https_shf_main_site_dog_owners_h_brand_url
    main_site_url_with(H_BRAND_DOG_OWNERS_URL_PART)
  end


  def https_shf_main_site_dog_owners_consumer_contact_url
    main_site_url_with(CONSUMER_CONTACT_FOR_DOG_OWNERS_URL_PART)
  end


  def https_shf_main_site_dog_owners_become_support_member_url
    main_site_url_with(BECOME_SUPPORT_MEMBER_DOG_OWNERS_URL_PART)
  end


  def https_shf_main_site_dog_owner_being_dog_owner_url
    main_site_url_with(BEING_A_DOG_OWNER_DOG_OWNERS_URL_PART)
  end


  # ----------------
  # For Companies
  #

  def https_shf_main_site_for_companies_url
    main_site_url_with(FOR_COMPANIES_URL_PART)
  end


  def https_shf_main_site_about_us_for_companies_url
    main_site_url_with(ABOUT_US_FOR_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_sign_up_url
    main_site_url_with(SIGN_UP_FOR_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_become_h_licensed_url
    main_site_url_with(BECOME_H_LICENSED_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_educational_reqs_url
    main_site_url_with(EDUCATIONAL_REQS_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_membership_commitment_url
    main_site_url_with(MEMEBERSHIP_COMMIT_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_ethics_guide_url
    main_site_url_with(MEMEBERSHIP_ETHICS_GUIDE_URL_PART)
  end


  def https_shf_main_site_companies_to_become_dog_co_url
    main_site_url_with(MEMEBERSHIP_TO_BECOME_DOG_CO_URL_PART)
  end


  def https_shf_main_site_companies_gdpr_url
    main_site_url_with(GDPR_COMPANIES_URL_PART)
  end


  def https_shf_main_site_companies_quality_control_companies_url
    main_site_url_with(QUALITY_CONTROL_COMPANIES_URL_PART)
  end


  # ---------------------------------------------------------------

  # I have this ending with 2 slashes because if someone called this by itself,
  # they would expect _both_ slashes
  #
  def https
    HTTPS
  end


  # -----------------------------------------------------------------------

  private

  # @return [String] -  the URL on the main site with the given page_url appended
  def main_site_url_with(page_url)
    make_https_url([SHF_MAIN_SITE_HOME_URL_PART, page_url])
  end


  # @return [String] - a valid URL that ends with a SLASH
  def make_https_url(list_of_parts)
    add_trailing_slash(https + list_of_parts.join(SLASH))
  end


  def add_trailing_slash(url)
    url.end_with?(SLASH) ? url : (url + SLASH)
  end
end
