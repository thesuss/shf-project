require 'rails_helper'
require 'shared_context/mock_app_configuration'

# ----------------------------------------------------------------------------

RSpec.shared_examples 'it uses the AppConfiguration site meta image' do
  it 'calls use_app_configuration' do
    expect(helper).to receive(:use_app_configuration)
    helper.meta_image_tags(FauxPath)
  end
end

# ----------------------------------------------------------------------------


RSpec.describe MetaImageTagsHelper, type: :helper do

  MOCK_BASE_URL   = 'http://test.host' unless defined?(MOCK_BASE_URL)

  let(:expected_base_url) { "#{MOCK_BASE_URL}/" }

  STORAGE_PATH   = File.join(Rails.public_path, 'storage', 'test')
  DEFAULT_IMG_FN = 'default_image_filename.png'
  IMG_PATH       = File.join(STORAGE_PATH, DEFAULT_IMG_FN)


  before(:all) do
    @storage_test_path = STORAGE_PATH
    @delete_storage_path_when_done = false # default

    # make the path for storage if it doesn't already exist
    unless File.exist?(@storage_test_path)
      @delete_storage_path_when_done = true
      FileUtils.mkdir_p @storage_test_path
    end

    FileUtils.copy_file(file_fixture('image.png'), File.join(@storage_test_path, DEFAULT_IMG_FN))
  end


  # only delete the storage path if it didn't exist before this test
  after(:all) do
    FileUtils.rm(File.join(@storage_test_path, DEFAULT_IMG_FN))
    FileUtils.rmdir(@storage_test_path) if @delete_storage_path_when_done
  end


  describe 'meta_image_tags' do

    describe 'the attachment' do

      context 'does not respond to :path' do
        it_behaves_like 'it uses the AppConfiguration site meta image'
      end

      context 'does respond to :path' do

        context 'does not respond to :url' do
          it_behaves_like 'it uses the AppConfiguration site meta image'
        end

        context 'does respond to :url' do

          context 'attachment exists' do

            it 'prepends the base url (protocl, host, port) and uses given attachment' do

              mock_attachment = MockAttachmentForFile.new(IMG_PATH)

              expect(helper).to receive(:image_tags)
                                    .with("#{MOCK_BASE_URL}#{IMG_PATH}",
                                          'png',
                                          width:  80,
                                          height: 80).and_call_original

              helper.meta_image_tags(mock_attachment)
            end

          end


          context 'attachment does not exist' do
            it_behaves_like 'it uses the AppConfiguration site meta image'
          end

        end

      end
    end


    describe 'if no image filename is given it uses the AppConfiguration site meta image' do
      it_behaves_like 'it uses the AppConfiguration site meta image'
    end

  end


  describe 'use_app_configuration' do

    it 'gets image, content_type, width and height from the AppConfiguration' do

      app_config = AdminOnly::AppConfiguration.config_to_use

      expect(app_config).to receive(:site_meta_image).and_call_original
      expect(app_config).to receive(:site_meta_image_content_type).and_return('jpg')
      expect(app_config).to receive(:site_meta_image_width).and_return(100)
      expect(app_config).to receive(:site_meta_image_height).and_return(200)

      expect(helper).to receive(:image_tags).with("#{MOCK_BASE_URL}#{FauxUrl.url}", 'jpg', width: 100, height: 200)

      helper.use_app_configuration
    end

  end


  describe 'image_tags(image_filename, image_type, width: 0, height: 0)' do

    it 'returns a hash with  image_src: and og:image, og:image:width, height, type' do

      expect(helper.image_tags(FauxUrl.url, 'image/blorf', width: 80, height: 80))
          .to match({ image_src: FauxUrl.url,
                      og:        {
                          image: {
                              _:      FauxUrl.url,
                              width:  80,
                              height: 80,
                              type:   'image/blorf'
                          }
                      }
                    })
    end

    it 'default image width = 0 if not specified' do
      expect(helper.image_tags(FauxUrl.url, 'image/png', height: 80))
          .to eq({ image_src: FauxUrl.url,
                   og:        {
                       image: {
                           _:      FauxUrl.url,
                           width:  0,
                           height: 80,
                           type:   'image/png'
                       }
                   }
                 })
    end

    it 'default image height is 0 if not specified' do
      expect(helper.image_tags(FauxUrl.url, 'image/png', width: 80))
          .to eq({ image_src: FauxUrl.url,
                   og:        {
                       image: {
                           _:      FauxUrl.url,
                           width:  80,
                           height: 0,
                           type:   'image/png'
                       }
                   }
                 })
    end

  end

end
