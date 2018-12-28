require 'rails_helper'


RSpec.describe CompaniesController, type: :controller do

  let(:no_query_params) { { "utf8" => "✓" } }


  describe '#index will fix_FB_changed_params' do

    it "does not change URL if there are no query ('q') parameters" do
      #    no_query_params = { "utf8" => "✓" }

      expected_fixed = { "utf8"       => "✓",
                         "controller" => "companies",
                         "action"     => "index"
      }

      get :index, params: no_query_params

      expect(subject.params.to_unsafe_h).to eq expected_fixed

    end

    it 'q parameters that are a Hash are converted to Array with the Hash values' do

      fb_mangled_params = { "utf8" => "✓",
                            "q"    => {
                                "business_categories_id_in" => { "0" => "1", "1" => "2", "2" => "3" }
                            }
      }

      expected_fixed_q = { "business_categories_id_in" => ["1", "2", "3"] }

      get :index, params: fb_mangled_params
      expect(subject.params.to_unsafe_h['q']).to eq expected_fixed_q
    end

    it 'empty values do not need to be retained)' do

      fb_mangled_params = { "utf8"   => "✓",
                            "q"      => {
                                "business_categories_id_in" => { "0" => "1", "1" => "2", "2" => "3" },
                                "addresses_region_id_in"    => { "0" => "6" },
                                "addresses_kommun_id_in"    => { "0" => nil, "1" => "" },
                                "name_in"                   => { "0" => nil } },
                            "commit" => "Sök" }

      expected_fixed_q = { "business_categories_id_in" => ["1", "2", "3"],
                           "addresses_region_id_in"    => ["6"],
                           "addresses_kommun_id_in"    => ["", ""],
                           "name_in"                   => [""] }


      get :index, params: fb_mangled_params

      expect(subject.params.to_unsafe_h['q']).to match expected_fixed_q
    end

  end


  describe '#index' do

    let(:region_stockholm) { create(:region, name: 'Stockholm', code: 'AB') }

    let(:stockholm_hundforum) do
      co = create(:company, name: 'Stockholms Hundforum',
                  street_address: 'Celsiusgatan 6',
                  post_code:      '112 30',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let(:stockholm_hundelska) do
      co = create(:company, name: 'Hundelska',
                  street_address: 'Rehnsgatan 15',
                  post_code:      '113 57',
                  region:         region_stockholm,
                  city:           'Stockholm')
      co.save # so it is geocoded
      co
    end

    let(:arsta_hundenshus) do
      co = create(:company, name: 'Hundens Hus',
                  street_address: 'Svärdlångsvägen 11 C',
                  post_code:      '120 60',
                  region:         region_stockholm,
                  city:           'Årsta')
      co.save # so it is geocoded
      co
    end

    let(:kista_hundkurs) do
      co = create(:company, name: 'HundKurs',
                  street_address: 'AKALLALÄNKEN 10',
                  region:         region_stockholm,
                  post_code:      '164 74',
                  city:           'Kista')
      co.save # so it is geocoded
      co
    end

    let(:member_hundforum) { create_member_with_co(stockholm_hundforum) }
    let(:member_hundelska) { create_member_with_co(stockholm_hundelska) }
    let(:member_hundenshus) { create_member_with_co(arsta_hundenshus) }
    let(:member_hundkurs) { create_member_with_co(kista_hundkurs) }


    def create_member_with_co(company)
      member                           = create(:member_with_membership_app)
      member.shf_application.companies = [company]
      create(:payment,
             :successful,
             user:         member,
             company:      company,
             payment_type: Payment::PAYMENT_TYPE_BRANDING
      )
      member
    end


    it 'params without :near or :within_coords returns all visible companies' do

      member_hundforum.save
      member_hundelska.save
      member_hundenshus.save
      member_hundkurs.save

      get :index, params: no_query_params

      all_visible_cos = @controller.view_assigns['all_visible_companies']
      expect(all_visible_cos.map { |co| co.name }).to match_array(['Stockholms Hundforum',
                                                                   'HundKurs',
                                                                   'Hundelska',
                                                                   'Hundens Hus'])
    end


    context 'search for locations near coordinates' do

      it "near: {latitude: '59.3251172, longitude: 18.0710935}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_coords_params = { "utf8" => "✓", near: { latitude:  '59.3251172',
                                                      longitude: '18.0710935' } }

        get :index, params: near_coords_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska',
                                                      'Hundens Hus'])
      end

      it "near: {latitude: '59.3251172, longitude: 18.0710935, distance: 3}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_coords_params = { "utf8" => "✓", near: { latitude:  '59.3251172',
                                                      longitude: '18.0710935',
                                                      distance:  3 } }

        get :index, params: near_coords_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska'])
      end


    end


    context 'search for locations :near' do

      it "near: {name: 'Stockholm'}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_stockholm_params = { "utf8" => "✓", near: { name: 'Stockholm' } }

        get :index, params: near_stockholm_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska',
                                                      'Hundens Hus'])
      end

      it "near: {name: 'Stockholm', distance: 2}" do
        member_hundforum.save
        member_hundelska.save
        member_hundenshus.save
        member_hundkurs.save

        near_stockholm_params = { "utf8" => "✓", near: { name: 'Stockholm', distance: 3 } }

        get :index, params: near_stockholm_params

        all_cos = @controller.view_assigns['all_companies']
        expect((all_cos).map(&:name)).to match_array(['Stockholms Hundforum',
                                                      'Hundelska'])
      end

    end

  end


  describe 'ignore sort by business category' do

    let(:no_q_params) { no_query_params.merge({ 'controller' => 'companies', 'action' => 'index' }) }

    it "does not change the params if there is no query ('q') parameter" do

      get :index, params: no_query_params
      expect(subject.params.to_unsafe_h).to eq no_q_params
    end


    it "does not change the params if there is no sort ('s') parameter" do

      business_cat_in = no_q_params.merge({ 'q' => { 'business_categories_id_in' => ["1"] } })
      get :index, params: business_cat_in

      expect(subject.params.to_unsafe_h).to eq business_cat_in
    end


    describe 'removes the sort param no matter the sort direction' do

      empty_query_request = {  "utf8" => "✓" ,
                               'controller' => 'companies', 'action' => 'index',
                               'q' => {} }

      sort_by_business_cats_no_dir = {desc: 'no direction', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name' } }) }
      sort_by_business_cats_asc    = {desc: 'asc', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name asc' } }) }
      sort_by_business_cats_desc   = {desc: 'desc', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name desc' } }) }
      sort_by_business_cats_blorf  = {desc: 'nonsense direction', request: empty_query_request.merge({ 'q' => { 's' => 'business_categories_name blorf' } }) }

      sort_dirs = [sort_by_business_cats_no_dir, sort_by_business_cats_asc,
                   sort_by_business_cats_desc, sort_by_business_cats_blorf
      ]

      sort_dirs.each do |sort_direction_request|

        it "removes the sort param with #{sort_direction_request[:desc]}" do
          get :index, params: sort_direction_request[:request]
          expect(subject.params.to_unsafe_h).to eq empty_query_request
        end
      end

    end # describe 'removes the sort param no matter the sort direction'


    it 'will not throw an error if a sort by business categories request is made' do
      bad_request = {  "utf8" => "✓" ,
                               'controller' => 'companies', 'action' => 'index',
                               'q' => { 's' => 'business_categories_name asc' }}

      expect{ get :index, params: bad_request}.not_to raise_error
    end

  end # describe 'ignore sort by business category'


end
