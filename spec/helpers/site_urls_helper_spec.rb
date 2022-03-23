require 'rails_helper'

RSpec.describe SiteUrlsHelper, type: :helper do

  describe 'the urls always end with a SLASH' do

    it 'adds a SLASH if needed' do
      # this is a way to test a private method
      expect(helper.send(:make_https_url, ['no-ending-slash'])).to eq 'https://no-ending-slash/'
    end

    it 'does not add a SLASH if the url already ends with one' do
      # this is a way to test a private method
      expect(helper.send(:make_https_url, ['no-ending-slash/'])).to eq 'https://no-ending-slash/'
    end
  end


  describe 'full urls that can be used' do

    it 'https' do
      expect(helper.https).to eq 'https://'
    end

    it 'https_main_site_home_url' do
      expect(helper.https_shf_main_site_home_url).to eq 'https://sverigeshundforetagare.se/'
    end


    it 'https_shf_main_site_contact_url' do
      expect(helper.https_shf_main_site_contact_url).to eq "#{helper.https_shf_main_site_home_url}kontakt/"
    end


    describe 'association' do

      it 'https_shf_main_site_association_url' do
        expect(helper.https_shf_main_site_association_url).to eq "#{helper.https_shf_main_site_home_url}broschyr/"
      end

      it 'https_shf_main_site_assn_brochure_url' do
        expect(helper.https_shf_main_site_assn_brochure_url).to eq "#{helper.https_shf_main_site_home_url}broschyr/"
      end

      it 'https_shf_main_assn_site_board_url' do
        expect(helper.https_shf_main_assn_site_board_url).to eq "#{helper.https_shf_main_site_home_url}styrelse/"
      end

      it 'https_shf_main_site_assn_membership_url' do
        expect(helper.https_shf_main_site_assn_membership_url).to eq "#{helper.https_shf_main_site_home_url}foretag/medlemsatagande/"
      end

      it 'https_shf_main_site_assn_statues_url' do
        expect(helper.https_shf_main_site_assn_statues_url).to eq "#{helper.https_shf_main_site_home_url}stadgar/"
      end

      it 'https_shf_main_site_assn_glossary_url' do
        expect(helper.https_shf_main_site_assn_glossary_url).to eq "#{helper.https_shf_main_site_home_url}ordlista/"
      end

      it 'https_shf_main_site_assn_history_url' do
        expect(helper.https_shf_main_site_assn_history_url).to eq "#{helper.https_shf_main_site_home_url}historik/"
      end
    end


    context 'for dog owners' do

      it 'https_shf_main_site_for_dog_owners_url' do
        expect(helper.https_shf_main_site_for_dog_owners_url).to eq "#{helper.https_shf_main_site_home_url}agare/"
      end


      it 'https_shf_main_site_dog_owners_about us_url' do
        expect(helper.https_shf_main_site_dog_owners_about_us_url).to eq "#{helper.https_shf_main_site_for_dog_owners_url}om-sveriges-hundforetagare/"
      end

      it 'https_shf_main_site_dog_owners_h_brand_url' do
        expect(helper.https_shf_main_site_dog_owners_h_brand_url).to eq "#{helper.https_shf_main_site_for_dog_owners_url}h-markt-av-sveriges-hundforetagare/"
      end

      it 'https_shf_main_site_dog_owners_consumer_contact_url' do
        expect(helper.https_shf_main_site_dog_owners_consumer_contact_url).to eq "#{helper.https_shf_main_site_for_dog_owners_url}konsumentkontakt/"
      end

      it 'https_shf_main_site_dog_owners_become a support member_url' do
        expect(helper.https_shf_main_site_dog_owners_become_support_member_url).to eq "#{helper.https_shf_main_site_for_dog_owners_url}bli-stodmedlem/"
      end

      it 'https_shf_main_site_dog_owners_become a dog owner_url' do
        expect(helper.https_shf_main_site_dog_owner_being_dog_owner_url).to eq "#{helper.https_shf_main_site_for_dog_owners_url}att-vara-hundagare/"
      end
    end


    context 'for companies' do

      it 'https_shf_main_site_for_companies_url' do
        expect(helper.https_shf_main_site_for_companies_url).to eq "#{helper.https_shf_main_site_home_url}foretag/"
      end

      it 'https_shf_main_site_about_us_for_companies_url' do
        expect(helper.https_shf_main_site_about_us_for_companies_url).to eq "#{helper.https_shf_main_site_for_companies_url}om-sveriges-hundforetagare/"
      end

      it 'https_shf_main_site_companies_become_h_licensed_url' do
        expect(helper.https_shf_main_site_companies_become_h_licensed_url).to eq "#{helper.https_shf_main_site_for_companies_url}bli-h-markt/"
      end

      it 'https_shf_main_site_companies_sign_up_url' do
        expect(helper.https_shf_main_site_companies_sign_up_url).to eq "#{helper.https_shf_main_site_for_companies_url}bli-medlem/"
      end

      it 'https_shf_main_site_companies_educational_reqs_url' do
        expect(helper.https_shf_main_site_companies_educational_reqs_url).to eq "#{helper.https_shf_main_site_for_companies_url}medlemskriterier/"
      end

      it 'https_shf_main_site_companies_membership_commitment_url' do
        expect(helper.https_shf_main_site_companies_membership_commitment_url).to eq "#{helper.https_shf_main_site_for_companies_url}medlemsatagande/"
      end

      it 'https_shf_main_site_companies_ethics_guide_url' do
        expect(helper.https_shf_main_site_companies_ethics_guide_url).to eq "#{helper.https_shf_main_site_for_companies_url}lima-guiden/"
      end

      it 'https_shf_main_site_companies_quality_control_companies_url' do
        expect(helper.https_shf_main_site_companies_quality_control_companies_url).to eq "#{helper.https_shf_main_site_for_companies_url}kvalitetskontroll/"
      end

      it 'https_shf_main_site_companies_gdpr_url' do
        expect(helper.https_shf_main_site_companies_gdpr_url).to eq "#{helper.https_shf_main_site_for_companies_url}gdpr/"
      end

      it 'https_shf_main_site_companies_to_become_dog_co_url' do
        expect(helper.https_shf_main_site_companies_to_become_dog_co_url).to eq "#{helper.https_shf_main_site_for_companies_url}vill-du-bli-hundforetagare/"
      end
    end
  end
end
