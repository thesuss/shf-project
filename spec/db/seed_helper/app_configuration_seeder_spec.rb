require 'rails_helper'

require_relative File.join(Rails.root, 'db/seed_helpers/app_configuration_seeder')


RSpec.describe SeedHelper::AppConfigurationSeeder do

  describe '.seed' do

    it 'explicitly calculates and saves the site meta image dimensions' do
      # will be called once with save, and then again explicitly after the save
      expect_any_instance_of(AdminOnly::AppConfiguration).to receive(:update_site_meta_image_dimensions).twice

      described_class.seed
    end

  end

end
