require 'rails_helper'
require 'email_spec/rspec'

require File.join(__dir__, 'shared_email_tests')

require_relative './previews/payment_mailer_preview'

RSpec.describe PaymentMailer, type: :mailer do

  RSpec.shared_examples 'a mail with common payment info' do

    it 'shows the klarna id' do
      expect(email_sent).to have_body_text(test_payment.klarna_id)
    end

    it 'shows the payment date' do
      expect(email_sent).to have_body_text(payment.updated_at.in_time_zone('Stockholm').strftime('%Y-%m-%d %H:%M:%S (%Z)'))
    end

    it 'shows the amount' do
      expect(email_sent).to have_body_text((test_payment.amount / 100).to_s)
    end

    it 'shows the no vat text' do
      expect(email_sent).to have_body_text(I18n.t('no_vat', scope: PAYMENT_MADE_SCOPE))
    end

  end

  let!(:test_user) { create(:member, membership_number: '42', email: 'user@example.com') }

  PAYMENT_MADE_SCOPE = 'mailers.payment_mailer.payment_made'

  NO_SIGNATURE = ''
  NO_SIGNOFF = ''

  describe 'membership_fee_payment_made' do

    let!(:test_payment) { create(:payment, user_id: test_user.id, payment_type: Payment::PAYMENT_TYPE_MEMBER, klarna_id: 'klarnaid', amount: 50_000) }
    let!(:email_sent) { PaymentMailer.payment_made(test_payment) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: PAYMENT_MADE_SCOPE, product: I18n.t('membership', scope: PAYMENT_MADE_SCOPE).capitalize),
                    'user@example.com',
                    'Firstname Lastname',
                    NO_SIGNATURE,
                    NO_SIGNOFF do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'a mail with common payment info' do
      let(:payment) { test_payment }
    end

    it 'shows the label for the membershipnumber' do
      expect(email_sent).to have_body_text(I18n.t('membership_number', scope: PAYMENT_MADE_SCOPE))
    end

    it 'shows the membershipnumber' do
      expect(email_sent).to have_body_text(test_user.membership_number)
    end

  end

  describe 'h_branding_fee_payment_made' do

    let!(:company) { test_user.companies.first }
    let!(:test_payment) { create(:payment, user_id: test_user.id, company_id: company.id, payment_type: Payment::PAYMENT_TYPE_BRANDING, klarna_id: 'klarnaid', amount: 50_000) }
    let!(:email_sent) { PaymentMailer.payment_made(test_payment) }

    it_behaves_like 'a successfully created email',
                    I18n.t('subject', scope: PAYMENT_MADE_SCOPE, product: I18n.t('h_brand', scope: PAYMENT_MADE_SCOPE)),
                    'user@example.com',
                    'Firstname Lastname',
                    NO_SIGNATURE,
                    NO_SIGNOFF do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'a mail with common payment info' do
      let(:payment) { test_payment }
    end

    it 'shows the label for the companynumber' do
      expect(email_sent).to have_body_text(I18n.t('company_number', scope: PAYMENT_MADE_SCOPE))
    end

    it 'shows the companynumber' do
      expect(email_sent).to have_body_text(company.company_number)
    end

  end

end
