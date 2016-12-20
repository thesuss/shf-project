require 'rails_helper'
RSpec.shared_examples "a swedish named resource" do |swedish_name, controller|

  let(:new)  { 'ny' }
  let(:edit) { 'redigera' }

  it "/#{swedish_name} = #index" do
    assert_routing({path: "#{swedish_name}", method: :get}, {controller: controller, action: 'index'})
  end

  it "/#{swedish_name}/ny = #create" do
    assert_routing({path: "#{swedish_name}", method: :post}, {controller: controller, action: 'create'})
  end

  it "/#{swedish_name}/ny = #new" do
    assert_routing({path: "#{swedish_name}/#{new}", method: :get}, {controller: controller, action: 'new'})
  end

  it "/#{swedish_name}/i/redigera = #edit" do
    assert_routing({path: "#{swedish_name}/1/#{edit}", method: :get}, {controller: controller, action: 'edit', id: '1'})
  end

  it "/#{swedish_name}/i = #show" do
    assert_routing({path: "#{swedish_name}/1", method: :get}, {controller: controller, action: 'show', id: '1'})
  end

  it "/#{swedish_name}/i = #update" do
    assert_routing({path: "#{swedish_name}/1", method: :patch}, {controller: controller, action: 'update', id: '1'})
  end

  it "/#{swedish_name}/i = #update" do
    assert_routing({path: "#{swedish_name}/1", method: :put}, {controller: controller, action: 'update', id: '1'})
  end

  it "/#{swedish_name}/i = #destroy" do
    assert_routing({path: "#{swedish_name}/delete", method: :delete}, {controller: controller, action: 'destroy', id: 'delete'})
  end

end



RSpec.describe "swedish named routes", :type => :routing do

  describe 'companies path = hundforetag, controller: CompaniesController' do

    it_should_behave_like "a swedish named resource", 'hundforetag', 'companies'

  end


  describe 'membership_applications path = ansokan, controller: MembershipApplicationsController' do

    it_should_behave_like "a swedish named resource", 'ansokan', 'membership_applications'

  end


  describe 'business_categories path = kategori, controller: BusinessCategoriesController' do

    it_should_behave_like "a swedish named resource", 'kategori', 'business_categories'

  end


end

RSpec.describe "SHF routes", :type => :routing do


  describe "new = 'ny' and edit = 'redigera'" do

    let(:new) {'ny'}
    let(:edit) {'redigera'}

    describe 'companies path = hundforetag, controller: CompaniesController' do

      before(:all) do
        Company.create(company_number: '2120000142', name: 'Bowsers',)
      end

      it '/hundforetag = #index' do
        assert_routing({path: 'hundforetag', method: :get}, {controller: 'companies', action: 'index'})
      end

      it '/hundforetag/ny = #create' do
        assert_routing({path: "hundforetag", method: :post}, {controller: 'companies', action: 'create'})
      end

      it '/hundforetag/ny = #new' do
        assert_routing({path: "hundforetag/#{new}", method: :get}, {controller: 'companies', action: 'new'})
      end

      it '/hundforetag/i/redigera = #edit' do
        assert_routing({path: "hundforetag/1/#{edit}", method: :get}, {controller: 'companies', action: 'edit', id: '1' })
      end

      it '/hundforetag/i = #show' do
        assert_routing({path: 'hundforetag/1', method: :get}, {controller: 'companies', action: 'show', id: '1' })
      end

      it '/hundforetag/i = #update' do
        assert_routing({path: "hundforetag/1", method: :patch}, {controller: 'companies', action: 'update', id: '1'})
      end

      it '/hundforetag/i = #update' do
        assert_routing({path: "hundforetag/1", method: :put}, {controller: 'companies', action: 'update', id: '1'})
      end

      it '/hundforetag/i = #destroy' do
        assert_routing({path: "hundforetag/delete", method: :delete}, {controller: 'companies', action: 'destroy', id: 'delete'})
      end

    end


    describe 'membership_applications path = ansokan, controller: MembershipApplicationsController' do
      
      it '/ansokan = #index' do
        assert_routing({path: 'ansokan', method: :get}, {controller: 'membership_applications', action: 'index'})
      end

      it '/ansokan/ny = #create' do
        assert_routing({path: "ansokan", method: :post}, {controller: 'membership_applications', action: 'create'})
      end

      it '/ansokan/ny = #new' do
        assert_routing({path: "ansokan/#{new}", method: :get}, {controller: 'membership_applications', action: 'new'})
      end

      it '/ansokan/i/redigera = #edit' do
        assert_routing({path: "ansokan/1/#{edit}", method: :get}, {controller: 'membership_applications', action: 'edit', id: '1' })
      end

      it '/ansokan/i = #show' do
        assert_routing({path: 'ansokan/1', method: :get}, {controller: 'membership_applications', action: 'show', id: '1' })
      end

      it '/ansokan/i = #update' do
        assert_routing({path: "ansokan/1", method: :patch}, {controller: 'membership_applications', action: 'update', id: '1'})
      end

      it '/ansokan/i = #update' do
        assert_routing({path: "ansokan/1", method: :put}, {controller: 'membership_applications', action: 'update', id: '1'})
      end

      it '/ansokan/i = #destroy' do
        assert_routing({path: "ansokan/delete", method: :delete}, {controller: 'membership_applications', action: 'destroy', id: 'delete'})
      end
      
    end

    
    describe 'business_categories path = kategori, controller: BusinessCategoriesController' do

      it '/kategori = #index' do
        assert_routing({path: 'kategori', method: :get}, {controller: 'business_categories', action: 'index'})
      end

      it '/kategori/ny = #create' do
        assert_routing({path: "kategori", method: :post}, {controller: 'business_categories', action: 'create'})
      end

      it '/kategori/ny = #new' do
        assert_routing({path: "kategori/#{new}", method: :get}, {controller: 'business_categories', action: 'new'})
      end

      it '/kategori/i/redigera = #edit' do
        assert_routing({path: "kategori/1/#{edit}", method: :get}, {controller: 'business_categories', action: 'edit', id: '1' })
      end

      it '/kategori/i = #show' do
        assert_routing({path: 'kategori/1', method: :get}, {controller: 'business_categories', action: 'show', id: '1' })
      end

      it '/kategori/i = #update' do
        assert_routing({path: "kategori/1", method: :patch}, {controller: 'business_categories', action: 'update', id: '1'})
      end

      it '/kategori/i = #update' do
        assert_routing({path: "kategori/1", method: :put}, {controller: 'business_categories', action: 'update', id: '1'})
      end

      it '/kategori/i = #destroy' do
        assert_routing({path: "kategori/delete", method: :delete}, {controller: 'business_categories', action: 'destroy', id: 'delete'})
      end

    end

  end

end