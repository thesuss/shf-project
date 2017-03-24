require 'rails_helper'

RSpec.describe CompaniesHelper, type: :helper do
  let!(:company) { create(:company) }

  describe 'companies' do
    let(:employee1) { create(:user) }
    let(:employee2) { create(:user) }
    let(:employee3) { create(:user) }

    let!(:ma1) do
      ma = create(:membership_application, :accepted,
                  user: employee1,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat1')
      ma
    end
    let!(:ma2) do
      ma = create(:membership_application, :accepted,
                  user: employee2,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat2')
      ma
    end
    let!(:ma3) do
      ma = create(:membership_application, :accepted,
                  user: employee3,
                  company_number: company.company_number)
      ma.business_categories << create(:business_category, name: 'cat3')
      ma
    end

    before(:all) do
      Company.delete_all
      MembershipApplication.delete_all
      User.delete_all
    end

    it '#last_category_name' do
      expect(helper.last_category_name(company)).to eq 'cat3'
    end

    it '#list_categories' do
      expect(helper.list_categories(company)).to eq 'cat1 cat2 cat3'
      expect(helper.list_categories(company)).not_to include 'Träning'
    end
  end

  describe '#full_uri' do

    let(:company) { build(:company) }

    it 'url starts with https://' do
      company.website = 'https://example.com'
      expect(helper.full_uri(company)).to eq "https://example.com"
    end

    it 'url starts with http://' do
      company.website = 'http://example.com'
      expect(helper.full_uri(company)).to eq "http://example.com"
    end

    it "url doesn't start with http" do
      company.website = 'example.com'
      expect(helper.full_uri(company)).to eq "http://example.com"
    end

  end


  describe '#location_and_markers_for' do

    it 'empty list of companies' do
      expect(helper.location_and_markers_for([])).to eq([])
    end

    it 'one company (name is linked to the company)' do
      co = build(:company)
      markers = helper.location_and_markers_for([co])
      expect(markers.count).to eq 1
      expect(markers.first[:latitude]).to eq co.main_address.latitude
      expect(markers.first[:longitude]).to eq co.main_address.longitude
      expect(markers.first[:text]).to eq(helper.html_marker_text(co))
      expect(markers.first[:text]).to include("#{link_to(co.name, co,target: '_blank')}")
    end

    it 'just show company name with no link for it' do
      co = build(:company)
      markers = helper.location_and_markers_for([co], link_name: false)
      expect(markers.first[:text]).not_to include("#{link_to(co.name, co,target: '_blank')}")
    end

  end


  describe '#html_marker_text' do

    let(:co) { create(:company, company_number: '8776682406')}

    it 'default links name to the company' do
      marker_text = helper.html_marker_text(co)
      expect(marker_text).to include( "#{link_to(co.name, co, target: '_blank')}" )
    end


    it 'name text = just the name (no link)' do
      marker_text = helper.html_marker_text(co, name_html: co.name)
      expect(marker_text).not_to include( "#{link_to(co.name, co, target: '_blank')}" )
    end

  end

end
