require 'rails_helper'

class PageMetaTagsSetterTestController < ApplicationController
  include PageMetaTagsSetter
end


RSpec.describe PageMetaTagsSetterTestController, type: :controller do

  MOCK_BASE_URL   = 'http://test.host'
  MOCK_REQ_PATH   = '/test-path'
  MOCK_ASSET_PATH = '/assets'

  let(:expected_base_url) { "#{MOCK_BASE_URL}#{MOCK_ASSET_PATH}/" }

  let(:default_title) { 'Hitta H-märkt hundföretag, hundinstruktör' }
  let(:default_full_title) { 'Hitta H-märkt hundföretag, hundinstruktör | Sveriges Hundföretagare' }
  let(:default_desc) { 'Här hittar du etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.' }
  let(:default_keywords) { 'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs' }
  let(:default_image_filename) { 'Sveriges_hundforetagare_banner_sajt.jpg' }
  let(:default_image_url) { "http://test.host/assets/#{default_image_filename}" }
  let(:default_image_width) { 1245 }
  let(:default_image_height) { 620 }
  let(:default_image_type) { 'image/jpeg' }


  before(:all) do
    @orig_locale = I18n.locale

    @meta_setter = PageMetaTagsSetterTestController.new
    @meta_setter.set_request! ActionDispatch::TestRequest.create
    @meta_setter.request.path = MOCK_REQ_PATH
  end

  after(:all) { I18n.locale = @orig_locale }


  describe 'set_meta_tags_for_url_path' do

    describe 'uses defaults if entries are not in the locale file' do

      before(:all) do

        @meta_setter.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

        # have to check results like this since the method calls set_meta_tags twice
        # and thus we could only check the second call with .to receive...
        @meta_tags_set = @meta_setter.send(:meta_tags).send(:meta_tags)
      end


      it 'default title = H-märkt hundföretag, hundinstruktör |  Sveriges Hundföretagare' do
        expect(@meta_tags_set['title']).to eq default_title
      end

      it 'default description = Etiska, svenska, H-märkta hundföretag. Du hittar bland annat hundinstruktörer, hundpsykologer, hunddagis, trim med mera.' do
        expect(@meta_tags_set['description']).to eq default_desc
      end

      it "default keywords = 'hund, hundägare, hundinstruktör, hundens entreprenör, Hundbolaget, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-markt, ansvarig, tjänat H-marknaden" do
        expect(@meta_tags_set['keywords']).to eq 'hund, hundägare, hundinstruktör, hundentreprenör, Sveriges Hundföretagare, svenskt hundföretag, etisk, H-märkt, hundkurs'
      end


      describe 'Facebook OpenGraph (og)' do

        it 'title = default title' do
          expect(@meta_tags_set['og']['title']).to eq default_full_title
        end

        it 'description = default description' do
          expect(@meta_tags_set['og']['description']).to eq default_desc
        end

        it 'type = website' do
          expect(@meta_tags_set['og']['type']).to eq 'website'
        end

        it 'url = http://test.host/test-path' do
          expect(@meta_tags_set['og']['url']).to eq 'http://test.host/test-path'
        end


        describe 'locale is the I18n.locale plus country string' do

          it "locale :sv = 'sv_SE'" do
            I18n.locale = :sv
            subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

            expect(subject.send(:meta_tags)
                       .send(:meta_tags)[:og][:locale]).to eq("sv_SE")
          end

          it "locale :en = 'en_US'" do
            I18n.locale = :en

            subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

            expect(subject.send(:meta_tags)
                       .send(:meta_tags)[:og][:locale]).to eq("en_US")
          end
        end


        describe 'image' do
          it 'name is the default image url' do
            expect(@meta_tags_set['og']['image']['_']).to eq default_image_url
          end
          it 'height = default image height' do
            expect(@meta_tags_set['og']['image']['height']).to eq default_image_height
          end
          it 'width = default image width' do
            expect(@meta_tags_set['og']['image']['width']).to eq default_image_width
          end

          it 'type = default image type' do
            expect(@meta_tags_set['og']['image']['type']).to eq default_image_type
          end
        end
      end


    end


    it 'appends Business Categories to list of keywords' do

      create(:business_category, name: 'category1')
      create(:business_category, name: 'category2')

      subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

      expect(subject.send(:meta_tags)
                 .send(:meta_tags)[:keywords]).to eq("#{default_keywords}, category1, category2")
    end


    it 'gets info from locale file' do

      I18n.locale = :sv

      # see https://github.com/rspec/rspec-mocks/issues/663 for more info on why
      # you cannot just stub I18n.t()

      # will return 'blorf' when it pretends (mocks) to look up something in a locale file
      allow(I18n.config.backend).to receive(:translate)
                                        .with(anything, anything, anything)
                                        .and_return('blorf')
      expected_result = {
          "site"        => 'Sveriges Hundföretagare',
          "title"       => 'blorf',
          "description" => 'blorf',
          "keywords"    => 'blorf',
          "og"          => {
              "title"       => 'blorf | Sveriges Hundföretagare',
              "description" => 'blorf',
              "url"         => 'http://test.host/test-path',
              "type"        => 'blorf',
              "locale"      => 'sv_SE',
              "image"       => {
                  "_"      => default_image_url,
                  "height" => default_image_height,
                  "type"   => default_image_type,
                  "width"  => default_image_width
              }
          },
          "twitter"     => {
              "card" => 'blorf'
          },
          "image_src"   => default_image_url
      }

      subject.set_meta_tags_for_url_path(MOCK_BASE_URL, MOCK_REQ_PATH)

      expect(subject.send(:meta_tags)
                 .send(:meta_tags)).to eq expected_result
    end

  end


  describe 'set_og_meta_tags (Facebook OpenGraph))' do

    describe 'defaults' do

      before(:all) do
        I18n.locale = :sv
        @meta_setter.set_og_meta_tags
        @meta_tags_set = @meta_setter.send(:meta_tags)['og']
      end

      it 'title' do
        expect(@meta_tags_set['title']).to eq "#{PageMetaTagsSetter::META_TITLE_DEFAULT} | #{PageMetaTagsSetter::META_SITE_NAME}"
      end

      it 'description' do
        expect(@meta_tags_set['description']).to eq PageMetaTagsSetter::META_DESC_DEFAULT
      end
      it 'type' do
        expect(@meta_tags_set['type']).to eq PageMetaTagsSetter::META_OG_DEFAULT_TYPE
      end
    end


    describe 'argument values passed in' do

      before(:all) do
        I18n.locale = :sv
        @meta_setter.set_og_meta_tags(title:       'page title',
                                      description: 'page description',
                                      type:        'the page type',
                                      base_url:    MOCK_BASE_URL,
                                      fullpath:    MOCK_REQ_PATH)
        @meta_tags_set = @meta_setter.send(:meta_tags)['og']
      end

      it 'title' do
        expect(@meta_tags_set['title']).to eq 'page title'
      end

      it 'description' do
        expect(@meta_tags_set['description']).to eq 'page description'
      end

      it 'type' do
        expect(@meta_tags_set['type']).to eq 'the page type'
      end

      it 'locale' do
        expect(@meta_tags_set['locale']).to eq 'sv_SE'
      end

    end

  end


  describe 'set_twitter_meta_tags' do

    it 'default: card = summary' do
      @meta_setter.set_twitter_meta_tags
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['twitter']['card']).to eq 'summary'
    end

    it "card = I18n.t('meta.twitter.card')" do
      @meta_setter.set_twitter_meta_tags(card: 'blorf')
      meta_tags_set = @meta_setter.send(:meta_tags)

      expect(meta_tags_set['twitter']['card']).to eq 'blorf'
    end
  end


  describe 'set_page_meta_images' do

    context 'looks up filename from the locale and gets the characteristics' do

      before(:all) do
        # temporarily add this file to the assets/images path
        @test_filename         = 'image.png'
        @asset_images_filepath = File.absolute_path(File.join(Rails.root, 'app', 'assets', 'images', @test_filename))
        @test_filename_url = /http:\/\/test.host\/assets\/image.png/

        @default_filename_url = /http:\/\/test.host\/assets\/#{I18n.t('meta.default.image_src')}/

        FileUtils.copy_file(file_fixture('image.png'), @asset_images_filepath)
      end

      after(:all) do
        FileUtils.remove_file(@asset_images_filepath)
      end


      describe 'image filename and url is given' do

        it 'uses the filename and provided url' do

          expect(@meta_setter).to receive(:set_page_meta_image_tags)
                                      .with(@test_filename_url,
                                            'png',
                                            width:  80,
                                            height: 80)

          @meta_setter.set_page_meta_images(@asset_images_filepath, @test_filename_url)
        end


        it 'if filename is not found, falls back to locale, then DEFAULT image' do

          expect(@meta_setter).to receive(:set_page_meta_image_tags)
                                      .with(@default_filename_url,
                                            PageMetaTagsSetter::META_IMAGE_DEFAULT_TYPE,
                                            width:  PageMetaTagsSetter::META_IMAGE_DEFAULT_WIDTH,
                                            height: PageMetaTagsSetter::META_IMAGE_DEFAULT_HEIGHT)

          @meta_setter.set_page_meta_images("blorfo-#{Time.now.to_i}", @test_filename_url)
        end

      end


      describe 'no image filename is given' do

        it 'first tries to look up filename from the locale and gets the characteristics' do
          allow(I18n.config.backend).to receive(:exists?)
                                            .with(:sv, '.meta.image_src')
                                            .and_return(true)
          allow(I18n.config.backend).to receive(:translate)
                                            .with(:sv, 'page_meta_tags_setter_test..meta.image_src', anything)
                                            .and_return(@test_filename)


          expect(@meta_setter).to receive(:set_page_meta_image_tags)
                                      .with(@test_filename_url,
                                            'png',
                                            width:  80,
                                            height: 80)
          @meta_setter.set_page_meta_images
        end


        it 'uses the default meta-image if no locale entry is found' do

          expect(@meta_setter).to receive(:set_page_meta_image_tags)
                                      .with(@default_filename_url,
                                            PageMetaTagsSetter::META_IMAGE_DEFAULT_TYPE,
                                            width:  PageMetaTagsSetter::META_IMAGE_DEFAULT_WIDTH,
                                            height: PageMetaTagsSetter::META_IMAGE_DEFAULT_HEIGHT)
          @meta_setter.set_page_meta_images
        end

      end


      it 'sets the OpenGraph info' do
        allow(I18n.config.backend).to receive(:exists?)
                                          .with(:sv, '.meta.image_src')
                                          .and_return(true)
        allow(I18n.config.backend).to receive(:translate)
                                          .with(:sv, 'page_meta_tags_setter_test..meta.image_src', anything)
                                          .and_return(@test_filename)

        @meta_setter.set_page_meta_images
        @meta_og_tags = @meta_setter.send(:meta_tags).send(:meta_tags)['og']

        puts("@meta_setter.meta_tags = #{@meta_setter.send(:meta_tags).send(:meta_tags)}")
        puts("@meta_og_tags_set = #{@meta_og_tags.inspect}")

        expect(@meta_og_tags['image']['_']).to eq "#{expected_base_url}#{@test_filename}"
        expect(@meta_og_tags['image']['type']).to eq 'image/png'
        expect(@meta_og_tags['image']['width']).to eq 80
        expect(@meta_og_tags['image']['height']).to eq 80
      end
    end

  end


  describe 'set_page_meta_image_tags(image_filename, image_type, width: 0, height: 0)' do

    let(:image_fn) { 'image.png' }
    let(:expected_image_url) { "#{expected_base_url}#{image_fn}" }


    it 'uses set_meta_tags to set image_src and og:image, og:image:width, height, type' do

      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  80,
                                             height: 80,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', width: 80, height: 80)
    end

    it 'default image width = 0 if not specified' do
      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  0,
                                             height: 80,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', height: 80)
    end

    it 'default image height = 0 if not specified' do
      expect(subject).to receive(:set_meta_tags)
                             .with({ image_src: expected_image_url,
                                     og:        {
                                         image: {
                                             _:      expected_image_url,
                                             width:  80,
                                             height: 0,
                                             type:   'image/png'
                                         }
                                     }
                                   })

      subject.set_page_meta_image_tags(expected_image_url, 'png', width: 80)
    end

  end


  describe 'set_page_meta_robots_none' do

    it 'uses set_meta_tags to set nofollow and noindex to true' do

      expect(subject).to receive(:set_meta_tags)
                             .with({ nofollow: true, noindex: true })

      subject.set_page_meta_robots_none

    end
  end


end
