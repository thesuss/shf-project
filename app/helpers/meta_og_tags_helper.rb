#--------------------------
#
# @module MetaOgTagsHelper
#
# @desc Responsibility: creates OpenGraph (og) meta info for a page
#
# This encapsulates all of the logic and info needed to create
# OpenGraph (og) tags for a page.
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-04
#
# @file meta_og_tags_helper.rb
#
#--------------------------
module MetaOgTagsHelper


  # Rails I18n usually uses a 2 letter language codes for the locale.
  # But Facebook's OpenGraph ('og') requires a language code and country (region)
  # code per the IETF language standard  https://en.wikipedia.org/wiki/IETF_language_tag
  # This is a simple mapping to the locales we're using.  If we start supporting
  # more languages and/or regions, this can be made more complex.
  LOCALES_TO_IETF = { sv: 'sv_SE',
                      en: 'en_US'
  } unless defined?(LOCALES_TO_IETF)


  # @return [Hash] - hash with key :og and value = the tags for Facebook OpenGraph (og)
  def og_meta_tags(site_name: AdminOnly::AppConfiguration.config_to_use.site_name,
                   title: full_page_title,
                   description: AdminOnly::AppConfiguration.config_to_use.site_meta_description,
                   type: AdminOnly::AppConfiguration.config_to_use.og_type,
                   base_url: '',
                   fullpath: '/')

    {
        og: {
            site_name:   site_name,
            title:       title,
            description: description,
            url:         base_url + fullpath,
            type:        type,
            locale:      meta_og_locale
        }
    }

  end


  # Set the OpenGraph (og) tags for a page.  Calls set_meta_tags and sets
  # the information in the :og key.
  #
  # @return [Hash] - the meta tags, which now include the :og key and values
  def set_og_meta_tags(site_name: AdminOnly::AppConfiguration.config_to_use.site_name,
                       title: full_page_title,
                       description: AdminOnly::AppConfiguration.config_to_use.site_meta_description,
                       type: AdminOnly::AppConfiguration.config_to_use.og_type,
                       base_url: '',
                       fullpath: '/')

    set_meta_tags og: {
        site_name:   site_name,
        title:       title,
        description: description,
        url:         base_url + fullpath,
        type:        type,
        locale:      meta_og_locale
    }
  end


  # ============================================================================


  private


  # get the IETF code for our current locale.  default is 'sv_SE'
  def meta_og_locale
    LOCALES_TO_IETF.fetch(I18n.locale, 'sv_SE')
  end


end
