require 'rails_helper'


RSpec.describe CompanyMetaInfoAdapter do

  let(:double_cat1) { instance_double(BusinessCategory, name: 'cat1') }
  let(:double_cat2) { instance_double(BusinessCategory, name: 'cat2') }
  let(:co_double) { instance_double(Company, { name: 'Co name', description: 'Co description',
                                               business_categories: [double_cat1, double_cat2],
                                               categories_names: ['cat1', 'cat2']}) }

  subject { described_class.new(co_double) }



  describe 'title' do

    context 'company name not blank' do
      it 'is the company name' do
        expect(subject.title).to eq 'Co name'
      end
    end

    context 'co name is blank' do
      it 'is the AppConfiguration site_meta_title' do
        blank_name_co = instance_double(Company, name: '')
        expect(AdminOnly::AppConfiguration).to receive(:config_to_use).and_return(double(AdminOnly::AppConfiguration, site_meta_title: 'app config site meta title'))
        expect(described_class.new(blank_name_co).title).to eq 'app config site meta title'
      end
    end
  end


  describe 'description' do

    context 'not blank' do
      it 'is the company description' do
        expect(subject.description).to eq 'Co description'
      end
    end

    context 'blank' do
      it 'is the AppConfiguration site_meta_description' do
        blank_desc_co = instance_double(Company, description: '')
        expect(described_class.new(blank_desc_co).description).to eq AdminOnly::AppConfiguration.config_to_use.site_meta_description
      end
    end

    it 'is santitized and spaces are squished' do
      co_html_desc = instance_double(Company,  description: "<p>something\n\n   &nbsp;</p>")

      expect(InputSanitizer).to receive(:sanitize_string).and_call_original
      expect(described_class.new(co_html_desc).description).to eq 'something'
    end
  end


  describe 'keywords' do

    context "not blank" do
      it "company.categories_names" do
        expect(co_double).to receive(:categories_names)
        expect(subject.keywords).to eq 'cat1, cat2'
      end
    end

    context 'blank' do

      it 'is the AppConfiguration AppConfiguration site_meta_description' do
        blank_cat_names_co = instance_double(Company, categories_names: ['  ', ' ', '', nil])
        expect(described_class.new(blank_cat_names_co).keywords).to eq AdminOnly::AppConfiguration.config_to_use.site_meta_keywords
      end
    end
  end


  describe 'og' do

    it 'is a Hash' do
      expect(subject.og).to be_a Hash
    end

    it '[:title] is the company.name' do
      expect(co_double).to receive(:name)
      expect(subject.og[:title]).to eq 'Co name'
    end

    it '[:description] is company.description' do
      expect(co_double).to receive(:description)
      expect(subject.description).to eq 'Co description'
    end

  end

end
