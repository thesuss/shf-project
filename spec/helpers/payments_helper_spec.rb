require 'rails_helper'
require 'shared_context/users'
require 'shared_context/named_dates'

include ApplicationHelper

RSpec.describe PaymentsHelper, type: :helper do

  let(:member_double) { instance_double(User) }
  let(:member_fee_double) { instance_double(Payment, user: member_double) }
  let(:co_double) { instance_double(Company) }
  let(:brand_fee_double) { instance_double(Payment, company: co_double) }

  before(:each) do
    allow(member_double).to receive(:is_a?).with(Company).and_return(false)
    allow(member_double).to receive(:is_a?).with(User).and_return(true)
    allow(co_double).to receive(:is_a?).with(Company).and_return(true)
    allow(co_double).to receive(:is_a?).with(User).and_return(false)
  end

  # Note that you have to call a helper method preceded with "helper." so that
  # it will correctly find and use the FontAwesome helper method :icon
  # (which is called from expire_date_label_and_value)

  describe 'expire_date_label_and_value' do
    before(:each) do
      allow(helper).to receive(:payment_due_now_hint_css_class).and_return(helper.no_css_class)
    end


    context 'user' do
      it 'returns the expiration date with the css class set' do
        expire_date = Time.zone.today + 1.month + 2.days
        allow(helper).to receive(:entity_expire_date).and_return(expire_date)

        response = /class="([^"]*)".*#{expire_date}/
        expect(helper.expire_date_label_and_value(member_double)).to match response
      end

      it 'returns tooltip explaining expiration date' do
        allow(helper).to receive(:entity_expire_date).and_return( Time.zone.today)

        response = /#{t('users.show.membership_expire_date_tooltip')}/
        expect(helper.expire_date_label_and_value(member_double)).to match response
      end

      it 'no expire date will show Paid through: None' do
        allow(helper).to receive(:entity_expire_date).with(member_double).and_return(nil)

        response = /.*#{t('users.show.term_paid_through')}.*#{t('none_t')}/
        expect(helper.expire_date_label_and_value(member_double)).to match response
      end
    end

    context 'company' do
      before(:each) do
        allow(helper).to receive(:entity_i18n_scope).and_return('companies')
      end

      it 'returns the expiration date with the css class set' do
        expire_date = Time.zone.today + 1.month + 2.days
        allow(helper).to receive(:entity_expire_date).and_return(expire_date)

        expect(helper.expire_date_label_and_value(brand_fee_double.company)).to match /class="([^"]*)".*#{expire_date}/
      end

      it 'returns tooltip explaining expiration date' do
        allow(helper).to receive(:entity_expire_date).and_return( Time.zone.today)

        expect(helper.expire_date_label_and_value(brand_fee_double.company)).to match /#{t('companies.show.branding_fee_expire_date_tooltip')}/
      end

      it 'no expire date will show Paid through: None' do
        allow(helper).to receive(:entity_expire_date).with(co_double).and_return(nil)

        response = /.*#{t('companies.show.term_paid_through')}.*#{t('none_t')}/
        expect(helper.expire_date_label_and_value(co_double)).to match response
      end
    end
  end


  describe 'entity_name_and_number_html' do

    context 'is a User' do
      it 'fullname m nr. membership_number with the membership number title and value surrounded by a span' do
        allow(member_double).to receive(:membership_number).and_return('12345')
        allow(member_double).to receive(:full_name).and_return('Member Full Name')

        expect(helper.entity_name_and_number_html(member_double, 'users.view_payment_receipts')).to match(/Member Full Name <span class=([^>]+)>(.+) 12345<\/span>/)
      end
    end

    context 'is a Company' do
      it 'company name org nr. company_number with the company_number number title and value surrounded by a span' do
        allow(co_double).to receive(:company_number).and_return('12345')
        allow(co_double).to receive(:name).and_return('Company Name')

        expect(helper.entity_name_and_number_html(co_double, 'companies.view_payment_receipts')).to match(/Company Name <span class=([^>]+)>(.+) 12345<\/span>/)
      end
    end
  end


  describe 'entity_name' do

    it 'full name if entity is a User' do
      allow(member_double).to receive(:full_name).and_return('First Last')
      expect(helper.entity_name(member_double)).to eq('First Last')
    end

    it 'name if the entity is a Company' do
      allow(co_double).to receive(:name).and_return('Some Company')
      expect(helper.entity_name(co_double)).to eq('Some Company')
    end

    it "t('name_missing') if entity is nil or not a User and not a Company" do
      else_result = I18n.t('name_missing')
      expect(helper.entity_name(nil)).to eq(else_result)
      expect(helper.entity_name('this string')).to eq(else_result)
    end
  end


  describe 'entity_expire_date' do
    let(:expire_date) { Time.zone.yesterday }

    it 'default is nil (if entity is nil)' do
      expect(entity_expire_date).to be_nil
    end

    it 'nil if entity is not a User or Company' do
      expect(entity_expire_date(7)).to be_nil
    end

    it 'entity.membership_expire_date if entity is a User' do
      allow(helper).to receive(:entity_value).with(member_double, anything, anything, anything).and_return(expire_date)
      expect(helper.entity_expire_date(member_double)).to eq(expire_date)
    end

    it 'entity.branding_expire_date if entity is a Company' do
      expect(co_double).to receive(:branding_expire_date).and_return(expire_date)
      expect(helper.entity_expire_date(co_double)).to eq(expire_date)
    end
  end


  describe 'entity_i18n_scope' do

    it 'default is "users"' do
      expect(entity_i18n_scope).to eq 'users'
    end

    it '"users" if the entity is a User' do
      expect(entity_i18n_scope(member_double)).to eq 'users'
    end

    it '"companies" if the entity is a Company' do
      expect(entity_i18n_scope(co_double)).to eq 'companies'
    end

    it '"users" if the entity is not a Company or User' do
      expect(entity_i18n_scope(7)).to eq 'users'
    end
  end


  describe 'payment_notes_label_and_value' do

    it "displays t('none_plur)' if there is no text to display" do
      expect(helper).to receive(:field_or_none)
                          .with(anything, I18n.t('none_plur'), anything)
      helper.payment_notes_label_and_value
    end

    it 'returns the HTML for payment notes label and display string (=field value)' do
      note_text = 'This is the payment note.'
      expect(helper).to receive(:field_or_none)
                          .with(anything, note_text, tag: :div)
      helper.payment_notes_label_and_value(note_text)
    end
  end


  describe 'payment_amount' do
    it 'empty string if payment amount is nil' do
      payment_double = instance_double(Payment, amount: nil)
      expect(payment_double).to receive(:amount)

      expect(helper.payment_amount(payment_double)).to eq ''
    end

    it 'is the payment amount / 100.00' do
      payment_double = instance_double(Payment, amount: 12345)
      expect(payment_double).to receive(:amount)

      expect(helper.payment_amount(payment_double)).to eq 123.45
    end
  end


  describe 'payment_amount_kr' do
    it 'appends [space] kr to the payment amount' do
      payment_double = instance_double(Payment, amount: 12345)
      expect(payment_double).to receive(:amount)

      expect(helper.payment_amount_kr(payment_double)).to eq '123.45 kr'
    end

    it 'empty string if payment amount is nil' do
      payment_double = instance_double(Payment, amount: nil)
      expect(payment_double).to receive(:amount)

      expect(helper.payment_amount_kr(payment_double)).to eq ''
    end
  end


  describe 'payment_due_hint returns string from I18n.t for the payment_due_status' do
    before(:each) { allow(member_double).to receive(:payment_expire_date).and_return Date.today }

    it 'status = :past_due' do
      allow(member_double).to receive(:payment_due_status).and_return(:past_due)
      expect(payment_due_hint(member_double)).to eq t('payors.past_due')
    end

    it 'status = :due' do
      allow(member_double).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_hint(member_double)).to eq t('payors.due')
    end

    it 'status = :due_by also requires a due_date' do
      allow(member_double).to receive(:payment_due_status).and_return(:due_by)
      allow(member_double).to receive(:payment_expire_date).and_return(Date.new(2019,11,11))
      expect(payment_due_hint(member_double)).to eq t('payors.due_by', due_date: '2019-11-11')
    end

    it 'status = :too_early' do
      allow(member_double).to receive(:payment_due_status).and_return(:too_early)
      expect(payment_due_hint(member_double)).to eq t('payors.too_early')
    end
  end


  describe 'payment_due_now_hint_css_class is based on entity.should_pay_now? and entity.too_early_to_pay?' do

    it 'returns yes css class if payment status is :too_early' do
      allow(member_double).to receive(:payment_due_status).and_return(:too_early)
      expect(payment_due_now_hint_css_class(member_double)).to eq helper.yes_css_class
    end

    it 'returns maybe css class if payment status is :due_by' do
      allow(member_double).to receive(:payment_due_status).and_return(:due_by)
      expect(payment_due_now_hint_css_class(member_double)).to eq helper.maybe_css_class
    end

    it 'returns no css class if the payment status is :past_due' do
      allow(member_double).to receive(:payment_due_status).and_return(:past_due)
      expect(payment_due_now_hint_css_class(member_double)).to eq helper.no_css_class
    end

    it 'returns no css class if payment status is :due' do
      allow(member_double).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_now_hint_css_class(member_double)).to eq helper.no_css_class

      allow(co_double).to receive(:payment_due_status).and_return(:due)
      expect(payment_due_now_hint_css_class(co_double)).to eq helper.no_css_class
    end

  end


  describe 'expires_soon_hint_css_class' do

    it 'returns yes css class if expire_date more than a month away' do
      expect(expires_soon_hint_css_class(Time.zone.today + 2.months)).to eq helper.yes_css_class
    end

    it 'returns maybe css class if expire_date less than a month away' do
      expect(expires_soon_hint_css_class(Time.zone.today + 2.days)).to eq helper.maybe_css_class
    end

    it 'returns no css class if expire_date has passed' do
      expect(expires_soon_hint_css_class(Time.zone.today - 2.days)).to eq helper.no_css_class
    end
  end


  describe 'payment_button_classes' do

    it 'default is to return %w(btn btn-secondary btn-sm)' do
      expect(payment_button_classes).to match_array(['btn', 'btn-secondary', 'btn-sm'])
    end

    it 'adds any given classes to the list of the default ones (order not important)' do
      expect(payment_button_classes(['another class', 'class2'])).to match_array(['btn', 'btn-secondary', 'btn-sm', 'another class', 'class2'])
    end
  end


  describe 'payment_button_tooltip_text' do

    describe 'i18n scope' do

      it "default is 'users'" do
        expect(payment_button_tooltip_text).to eq t("users.show.payment_tooltip")
      end

      it 'pass in a different scope' do
        expect(payment_button_tooltip_text(t_scope: 'companies')).to eq t("companies.show.payment_tooltip")
      end

      it 'if given i18n scope not found, will use "users" scope' do
        expect(payment_button_tooltip_text(t_scope: 'blorf')).to eq t("users.show.payment_tooltip")
      end
    end

    describe 'payment_due_now determines if "no payment due now" message shows' do

      it 'default is true (does not show "no payment due now" message)' do
        expect(payment_button_tooltip_text).not_to include t('payors.no_payment_due_now')
      end

      it 'false will show "no payment due now" message' do
        expect(payment_button_tooltip_text(payment_due_now: false)).to include t('payors.no_payment_due_now')
      end
    end

  end
end
