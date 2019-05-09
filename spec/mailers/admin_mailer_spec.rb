require 'rails_helper'
require 'email_spec/rspec'


require File.join(__dir__, 'shared_email_tests')

require_relative './previews/admin_mailer_preview'

# Ensure that the mail can be created
#  and the subject, recipient, and greeting are correct
#
RSpec.describe AdminMailer, type: :mailer do

  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let!(:test_user) { create(:user, email: 'user@example.com') }


  describe '#new_shf_application_received' do

    let(:new_app) { create(:shf_application, user: test_user)  }
    let(:admin) { create(:user, email: 'admin@example.com', admin: true) }
    let(:email_sent) { AdminMailer.new_shf_application_received(new_app, admin) }

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.new_application_received.subject'),
                    'admin@example.com',
                    'Firstname Lastname',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

    it 'has text for the number of files uploaded' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other'))
    end

    describe 'shows the number of files uploaded' do

      UPLOAD_FIXTURES_DIR = File.join(Rails.root, 'spec', 'fixtures','uploaded_files')

      it 'no files uploaded' do
        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 0')
      end

      it '1 file uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files.create(actual_file: File.open(fn1, 'r') )

        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 1')
      end

      it '3 files uploaded' do
        fn1 = File.join(UPLOAD_FIXTURES_DIR, 'diploma.pdf')
        new_app.uploaded_files.create(actual_file: File.open(fn1, 'r') )
        fn2 = File.join(UPLOAD_FIXTURES_DIR, 'image.jpg')
        new_app.uploaded_files.create(actual_file: File.open(fn2, 'r') )
        fn3 = File.join(UPLOAD_FIXTURES_DIR, 'image.gif')
        new_app.uploaded_files.create(actual_file: File.open(fn3, 'r') )

        expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.shf_application.uploaded_files.other') + ': 3')
      end
    end


    it 'has the company number' do
      expect(email_sent).to have_body_text(I18n.t('activerecord.attributes.company.company_number'))
      expect(email_sent).to have_body_text(new_app.companies.first.company_number)
    end

  end


  describe '#member_unpaid_over_x_months' do

    let(:new_app) { create(:shf_application, user: test_user)  }

    let(:mon_ago_5) { Time.zone.now - 5.months }

    let(:past_member1) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member1')
      memb.companies.first.update(website: 'website1')
      memb.issue_membership_number
      memb
    end

    let(:past_member2) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member2')
      memb.companies.first.update(website: 'website2')
      memb.issue_membership_number
      memb
    end

    let(:past_member3) do
      memb = create(:member_with_expiration_date, expiration_date: mon_ago_5, first_name: 'Member3')
      memb.companies.first.update(website: 'website3')
      memb.issue_membership_number
      memb
    end

    let(:members_5_mon_overdue) { [ past_member1, past_member2, past_member3 ] }

    let(:admin) { create(:user, email: 'admin@example.com', admin: true) }

    let(:num_months) { 5 }
    let(:email_sent) { AdminMailer.member_unpaid_over_x_months(admin, members_5_mon_overdue, num_months) }


    describe 'number of months' do

      it 'defaults to 6 months' do

        # have to stub out all these translate calls so we can catch the 1 with :num_months
        allow(I18n).to receive(:translate).with(anything, { raise: true }).and_return('ok')
        allow(I18n).to receive(:translate).with('full_name', anything).and_return('ok')
        allow(I18n).to receive(:translate).with("these_are_unpaid", anything).and_return('ok')
        allow(I18n).to receive(:translate).with("mailers.application_mailer.greeting", anything).and_return('ok')
        allow(I18n).to receive(:translate).with("mailers.application_mailer.footer.text.email_sent_to", anything).and_return('ok')

        expect(I18n).to receive(:translate).with('member_unpaid_over_x_months.subject',
                                                 {num_months: 6, scope: 'mailers.admin_mailer'})

        subject.member_unpaid_over_x_months(admin, members_5_mon_overdue )
      end

    end

    describe 'lists members not paid for X months' do

      it 'name, membership number, and website is listed' do

        expect(email_sent).to have_body_text('Member1 Lastname')
        expect(email_sent).to have_body_text('Member2 Lastname')
        expect(email_sent).to have_body_text('Member3 Lastname')

        expect(email_sent).to have_body_text(past_member1.membership_number)
        expect(email_sent).to have_body_text(past_member2.membership_number)
        expect(email_sent).to have_body_text(past_member3.membership_number)

        expect(email_sent).to have_body_text('website1')
        expect(email_sent).to have_body_text('website2')
        expect(email_sent).to have_body_text('website3')

      end

      it 'if there is more than 1 company, websites for all companies are shown' do
        past_member2.shf_application.companies.append(past_member1.companies.first)

        # order can be either website2 website1 OR website1 website2
        expect(email_sent).to have_body_text(/((website1 website2)|(website2 website1))/)
      end

    end

    it_behaves_like 'a successfully created email',
                    I18n.t('mailers.admin_mailer.member_unpaid_over_x_months.subject', num_months: 5),
                    ENV['SHF_MEMBERSHIP_EMAIL'],
                    'Firstname Lastname',
                    I18n.t('mailers.admin_mailer.signoff') do
      let(:email_created) { email_sent }
    end

    it_behaves_like 'from address is correct' do
      let(:mail_address) { email_sent.header['from'] }
    end

    it_behaves_like 'reply-to address is correct' do
      let(:email_created) { email_sent }
    end

  end

  it 'has a previewer' do
    expect(AdminMailerPreview).to be
  end


end
