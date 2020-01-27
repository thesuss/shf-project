#!/usr/bin/ruby

require 'mini_magick'
require 'meta_og_tags_helper'


#--------------------------
#
# @module MetaTagsHelper
#
# @desc Responsibility: Creates the meta tags for a page. If no specific value is
# provided for a tag, information from the current Application Configuration is used.
#
# @example In the CompaniesController, use the defaults for the :index action
#     but set the title tag specifically for a company that is being displayed
#     with the :show action:
#      (Note there really would be more meta-tag info set for a Company.)
#
#     Set nofollow and noindex to true for the
#     :edit action with the :meta_robots_none method
#
#       class CompaniesController
#
#         include PageMetaInfoSetter
#
#         # Add this code in the :show method:
#         def show
#           ...
#           set_meta_tags title: @company.name
#           ...
#         end
#
#       end
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-07
#
# @file meta_tags_helper.rb
#
#--------------------------


module MetaTagsHelper

  include MetaOgTagsHelper


  # Set the meta tags for a page that has the given url + fullpath.
  # The base_url and request fullpath are needed so that the full URL can
  # be put into meta tags (e.g. og.url)
  # The site meta image is set with a helper: MetaImageTagsHelper#meta_image_tags
  # After this is called, a Controller or view can override or add to any of
  # the meta-tag information that this has set by calling :set_meta_tags again.
  #
  def meta_tags_for_url_path(base_url, request_fullpath)

    app_config = AdminOnly::AppConfiguration.config_to_use
    site_name  = app_config.site_name
    page_title = app_config.site_meta_title
    page_desc  = app_config.site_meta_description

    tags = {
        site:        site_name,
        title:        page_title,
        description: page_desc,
        keywords:    create_keywords(app_config.site_meta_keywords)
    }

    tags.merge!(og_meta_tags(site_name:   site_name,
                             title:       full_page_title(page_title: app_config.site_meta_title),
                             description: page_desc,
                             type:        app_config.og_type,
                             base_url:    base_url,
                             fullpath:    request_fullpath))

    tags = combine_meta_image_tags(tags, meta_image_tags)

    tags.merge!(facebook_meta_tags)
        .merge!(twitter_meta_tags)
    tags
  end


  def facebook_meta_tags(app_id: AdminOnly::AppConfiguration.config_to_use.facebook_app_id)
    { fb: { app_id: app_id } }
  end


  def twitter_meta_tags(card: AdminOnly::AppConfiguration.config_to_use.twitter_card_type)
    { twitter: { card: card } }
  end


  def meta_robots_none
    { nofollow: true,
      noindex:  true }
  end


  # ============================================================================


  private

  # @return [Hash] - combine the meta image tags with the given hash, being careful
  #    to combine the og: sub-hash
  def combine_meta_image_tags(given_hash, image_tags)

    key_is_og = lambda {|k, _v| k == :og}
    combined_not_og = given_hash.reject(&key_is_og).merge(image_tags.reject(&key_is_og))

    combined_og = given_hash.fetch(:og, {}).merge(image_tags.fetch(:og, {}))
    combined_not_og[:og] = combined_og
    combined_not_og
  end


  # Append all BusinessCategories to the site keywords
  #
  # @param [String] site_keywords - keywords for the site
  # @return [String] - a string of comma-separated keywords
  def create_keywords(site_keywords = '')

    business_cats = BusinessCategory.pluck(:name).uniq.sort

    cats_str      = business_cats.empty? ? '' : ', ' + business_cats.join(', ')
    site_keys_str = site_keywords.nil? ? '' : site_keywords
    site_keys_str + cats_str
  end

end
