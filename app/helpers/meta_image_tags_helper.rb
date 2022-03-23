require 'mini_magick'


#--------------------------
#
# @module MetaImageTagsHelper
#
# @desc Responsibility: Creates meta information for an image
# If no specific value is provided for a tag, information is looked up in
# the application configuration.
#
# This encapsulates all of the logic and info needed to create image tags.
# It's complicated enough to justify pulling out into its own module.
#
# ImageMagick is used to get the image type, width, and height.
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-04-25
#
# @file meta_image_tags_helper.rb
#
#--------------------------
module MetaImageTagsHelper


  # Return a Hash with meta tags for the image.
  # If no attachment_image is provided or if it doesn't exist,
  #   use the AppConfiguration meta image info
  #
  # @param [String] attachment_image - the attachment_image (responds to :path and :url)
  #     (e.g. a Paperclip attachment)
  #
  def meta_image_tags(attachment_image = nil)

    # The file must exist in public/storage and respond to :path and :url
    if attachment_image &&
        attachment_image.respond_to?(:path) && attachment_image.respond_to?(:url) &&
        File.exist?(attachment_image.path)

      # make a temp. copy of the file just to be safe
      image = MiniMagick::Image.new(attachment_image.path)

      image_tags(public_url_to_image(attachment_image.url),
                 image.type.downcase,
                 width:  image.width,
                 height: image.height)
    else
      use_app_configuration
    end

  end


  def use_app_configuration
    full_site_image_url = public_url_to_image(AdminOnly::AppConfiguration.config_to_use.site_meta_image.url)
    image_tags(full_site_image_url,
               AdminOnly::AppConfiguration.config_to_use.site_meta_image_content_type,
               width:  AdminOnly::AppConfiguration.config_to_use.site_meta_image_width,
               height: AdminOnly::AppConfiguration.config_to_use.site_meta_image_height)
  end


  # Given the image filename for an image (ex: 'Sveriges_hundforetagare_banner_sajt.jpg')
  # create the right meta tags for that image:
  #   - image_src
  #   - og:image (including the type, height, and width)
  #
  # I use keyword params for width and height because I personally have to
  # look up param order whenever there's both a width and height to see what
  # order is wanted. Keywords solve that.
  #
  # @param image_url [String] - the publicly available URL for the file
  # @param [String] image_type -  the string representing the image type, to tell OpenGraph the type (e.g. 'jpeg', 'png', etc.)
  # @param [Integer] width - width of the image if known; will be used if given
  # @param [Integer] height - height of the image if known; will be used if given
  #
  # @return [Hash] - hash with keys set for the image and OG tags
  def image_tags(image_url, image_type, width: 0, height: 0)

    { image_src: image_url,
      og:        {
          image: {
              _:      image_url,
              type:   image_type,
              width:  width,
              height: height
          }
      }
    }
  end


  # ============================================================================


  private


  def public_url_to_image(image_url)
    "#{request.protocol}#{request.host_with_port}#{image_url}"
  end

end
