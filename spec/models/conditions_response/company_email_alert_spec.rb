require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'

require 'shared_context/stub_email_rendering'

# Note that the described class is _not_ an ActiveRecord, so the database is not
# automatically cleaned between examples.

RSpec.describe CompanyEmailAlert do


  # define subject this way since this is a Singleton
  let(:subject) { described_class.instance }

  let(:jan1) { Date.new(2019, 1, 1) }
  let(:jun1) { Date.new(2019, 6, 1) }
  let(:jun6) { Date.new(2019, 6, 6) }

  let(:c1_all_paid) { create(:company, name: 'company1') }
  let(:member1_c1_exp_jun6) { create(:member, membership_status: :current_member, last_day: jun6, company_number: c1_all_paid.company_number, email: 'member1_c1_exp_jun6@example.com' )}

  let(:c2_2_members) { create(:company, name: 'company2') }
  let(:member1_c2_exp_jun6) { create(:member, membership_status: :current_member, last_day: jun6, company_number: c2_2_members.company_number, email: 'member_lastday_jun_6@example.com') }
  let(:member2_c2_exp_jun1) { create(:member, membership_status: :current_member, last_day: jun1, company_number: c2_2_members.company_number, email: 'member_lastday_jun_1@example.com') }


  describe '.send_email' do

    include_context 'stub email rendering'

    let(:mock_log) { instance_double("ActivityLogger") }

    around(:each) do |example|
      Timecop.freeze(jan1)
      example.run
      Timecop.return
    end


    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)

      subject.create_alert_logger(mock_log)
    end


    context 'successful' do

      it 'delivers email to each member and logs each one' do
        member1_c2_exp_jun6
        member2_c2_exp_jun1
        allow(c2_2_members).to receive(:current_members).and_return([member1_c2_exp_jun6, member2_c2_exp_jun1])

        allow(subject).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

        expect(subject.mailer_class).to receive(:h_branding_fee_past_due)
            .exactly(c2_2_members.current_members.size).times
            .and_call_original

        expect(mock_log).to receive(:info).with("CompanyEmailAlert email sent to user id: #{member1_c2_exp_jun6.id} email: #{member1_c2_exp_jun6.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}.")
        expect(mock_log).to receive(:info).with("CompanyEmailAlert email sent to user id: #{member2_c2_exp_jun1.id} email: #{member2_c2_exp_jun1.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}.")

        c2_2_members.current_members.each do | c2_2_member |
          subject.send_email(c2_2_members, c2_2_member, mock_log)
        end

        expect(ActionMailer::Base.deliveries.size).to eq(c2_2_members.current_members.size)
      end
    end

    context 'failure' do

      it 'logs the failure info' do
        member1_c2_exp_jun6
        member2_c2_exp_jun1

        allow(c2_2_members).to receive(:current_members).and_return([member1_c2_exp_jun6, member2_c2_exp_jun1])
        allow(subject).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

        expect(subject.mailer_class).to receive(:h_branding_fee_past_due)
                                                    .exactly(c2_2_members.current_members.size).times
                                                    .and_return(Net::ProtocolError)

        # These errors will be logged:
        expect(mock_log).to receive(:error).with(/CompanyEmailAlert email ATTEMPT FAILED to user id: #{member1_c2_exp_jun6.id} email: #{member1_c2_exp_jun6.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}\. undefined method `deliver_now' for Net::ProtocolError:Class Also see (.*)/)
        expect(mock_log).to receive(:error).with(/CompanyEmailAlert email ATTEMPT FAILED to user id: #{member2_c2_exp_jun1.id} email: #{member2_c2_exp_jun1.email} company id: #{c2_2_members.id} name: #{c2_2_members.name}\./)

        c2_2_members.current_members.each do | member |
          subject.send_email(c2_2_members, member, mock_log)
        end

        expect(ActionMailer::Base.deliveries.size).to eq 0
      end
    end
  end


  describe '.entities_to_check' do

    it 'returns all companies (Company.all)' do
      # create companies and everything.
      c1 = create(:company, name: 'c1')
     # c2 = create(:company, name: 'c2')
     # c3 = create(:company, name: 'c3')

      NEWLINE = "\n"
      actual = subject.entities_to_check.to_a
      expect(actual).to match_array([c1]), "\n was: #{actual.map{|c| c.inspect.to_s + NEWLINE } }"
    end
  end


  it '.mail_message sends both company and member as args to the mailer_method' do

    allow(subject).to receive(:mailer_method).and_return(:h_branding_fee_past_due)

    allow(subject.mailer_class).to receive(:h_branding_fee_past_due)
        .with(c1_all_paid, member1_c1_exp_jun6)
        .and_return('it worked!')

    expect(subject.mail_message(c1_all_paid, member1_c1_exp_jun6)).to eq 'it worked!'
  end

  it '.mailer_class is MemberMailer because it sends out emails to members of companies' do
    expect(subject.mailer_class).to eq MemberMailer
  end


  it '.company_recipients returns all current_members' do
    travel_to jan1 do
      member1_c2_exp_jun6
      member2_c2_exp_jun1

      expect(c2_2_members).to receive(:current_members).and_return([member1_c2_exp_jun6, member2_c2_exp_jun1])
      expect(subject.company_recipients(c2_2_members)).to match_array([member1_c2_exp_jun6, member2_c2_exp_jun1])
    end
  end


  it '.success_str returns a string with member and company info' do
    expect(subject.success_str(c1_all_paid, member1_c1_exp_jun6))
        .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company id: #{c1_all_paid.id} name: company1"
  end


  describe '.failure_str' do

    context 'company is nil' do
      it 'member is nil prints nil for both' do
        expect(subject.failure_str(nil, nil))
            .to eq "to user is nil company is nil"
      end

      it 'member is not nil prints nil for the company and member id and email' do
        expect(subject.failure_str(nil, member1_c1_exp_jun6))
            .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company is nil"
      end
    end # context 'company is nil'

    context 'company is not nil' do
      it 'member is nil prints nil for member and company info' do
        expect(subject.failure_str(c1_all_paid, nil))
            .to eq "to user is nil company id: #{c1_all_paid.id} name: company1"
      end

      it 'member is not nil prints info for both company and member id and email' do
        expect(subject.failure_str(c1_all_paid, member1_c1_exp_jun6))
            .to eq "to user id: #{member1_c1_exp_jun6.id} email: #{member1_c1_exp_jun6.email} company id: #{c1_all_paid.id} name: company1"
      end
    end # context 'company is nil'

  end # describe '.failure_str'


end
