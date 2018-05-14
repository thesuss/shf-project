require 'rails_helper'

RSpec.describe 'selective loading of external assets on specific pages' do

  before(:each) { view.lookup_context.prefixes +=
                   ['application', 'companies', 'shf_documents'] }

  describe 'hips.js' do

    let(:member_payment) do
      create(:payment, status: Payment::ORDER_PAYMENT_STATUS['successful'],
                       expire_date: Time.zone.today + 1.day)
    end

    it 'is loaded on payments/create' do
      assign(:payment, member_payment)
      assign(:hips_id, '12345')

      render template: 'payments/create', layout: 'layouts/application'

      expect(rendered).to have_xpath("//head/script[contains(@src,'hips.js')]",
                                     visible: false)
    end

    it 'is not loaded on other pages' do
      allow(view).to receive(:current_user) { Visitor.new }

      assign(:all_visible_companies, [])
      assign(:all_companies, Company.all)
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render template: 'companies/index', layout: 'layouts/application'

      expect(rendered).not_to have_xpath("//head/script[contains(@src,'hips.js')]",
                                         visible: false)
    end
  end

  describe 'ckeditor.js' do
    let(:document) { create(:shf_document, :txt) }
    let(:company)  { create(:company) }

    it 'is loaded on companies/edit' do
      assign(:company, company)

      render template: 'companies/edit', layout: 'layouts/application'

      expect(rendered).to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                     visible: false)
    end

    it 'is loaded on shf_documents/contents_edit' do
      assign(:page, document.actual_file_file_name)
      assign(:title, document.title)
      assign(:contents, 'This if the document contents')

      render template: 'shf_documents/contents_edit', layout: 'layouts/application'

      expect(rendered).to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                     visible: false)
    end

    it 'is not loaded on other pages' do
      allow(view).to receive(:current_user) { Visitor.new }
      assign(:company, company)
      assign(:shf_document, document)

      without_partial_double_verification do
        # http://rspec.info/blog/2017/05/rspec-3-6-has-been-released/
        allow(view).to receive(:policy).and_return(double('cmpy policy',
                                                          update?: false,
                                                          index?: false,
                                                          destroy?: false))

        render template: 'companies/show', layout: 'layouts/application'
        expect(rendered).not_to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                           visible: false)

        render template: 'shf_documents/show', layout: 'layouts/application'
        expect(rendered).not_to have_xpath("//head/script[contains(@src,'ckeditor.js')]",
                                           visible: false)
      end
    end
  end
end
