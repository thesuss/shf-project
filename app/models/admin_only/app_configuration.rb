module AdminOnly

  class AppConfiguration < ApplicationRecord
    # Aggregates discrete data items that are used to configure
    # various aspects of the system (app).

    has_attached_file :chair_signature,
                      url: :url_for_images,
                      default_url: 'chair_signature.png',
                      styles: { standard: ['250'] },
                      default_style: :standard

    has_attached_file :shf_logo,
                      url: :url_for_images,
                      default_url: 'shf_logo.png',
                      styles: { standard: ['250'] },
                      default_style: :standard

    validates_attachment_content_type :chair_signature, :shf_logo,
                                      content_type:  /\Aimage\/.*(jpeg|png)\z/

    validates_attachment_file_name :chair_signature, :shf_logo,
                                   matches: [/png\z/, /jpe?g\z/]

    private

    def url_for_images
      '/storage/app_configuration/images/:attachment/:hashed_path/:style_:basename.:extension'
    end
  end
end
