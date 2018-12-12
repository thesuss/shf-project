require 'rails_helper'

RSpec.describe MembershipNotPaidAlert, type: :model do

  let(:dec_1) { Time.zone.local(2018, 12, 1) }
  let(:dec_2) { Time.zone.local(2018, 12, 2) }
  let(:dec_3) { Time.zone.local(2018, 12, 3) }
  let(:nov_30_next_year) { Time.zone.local(2019, 11, 30) }

  let(:success) { Payment.order_to_payment_status('successful') }

  let(:config) { { days: [1, 3, 5] } }

  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '.send_alert_this_day?(config, user)' do

    context 'user has an approved application' do

      context 'next membership payment is past due' do

        let(:membership_app) do
          app = create(:shf_application, :accepted, updated_at: dec_1)
          app.update(created_at: dec_1)
          app
        end

        let(:user) { membership_app.user }


        it "true when today is in the config list of days to send the alert" do
          expect(described_class.send_alert_this_day?(config, user, dec_2)).to be_truthy
        end

        it 'false when today is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, user, dec_3)).to be_falsey
        end
      end


      context 'next membership payment is NOT past due' do

        let(:membership_app) do
          app = create(:shf_application, :accepted, updated_at: dec_1)
          app.update(created_at: dec_1)
          app_user = app.user

          create(:payment, user: app_user, status: success,
                 payment_type: Payment::PAYMENT_TYPE_MEMBER,
                 start_date: dec_1,
                 expire_date: nov_30_next_year)
          app
        end

        let(:user) { membership_app.user }

        it "false when today is in the config list of days to send the alert" do
          expect(described_class.send_alert_this_day?(config, user, dec_2)).to be_falsey
        end

        it 'false when today is not in the config list of days to send the alert' do
          expect(described_class.send_alert_this_day?(config, user, dec_3)).to be_falsey
        end

      end # context 'next membership payment is NOT past due'
    end


    context 'user does NOT have an approved application (= always false)' do

      let(:user) { create( :user ) }

      it "false when today is in the config list of days to send the alert" do
        expect(described_class.send_alert_this_day?(config, user, dec_2)).to be_falsey
      end

      it 'false when today is not in the config list of days to send the alert' do
        expect(described_class.send_alert_this_day?(config, user, dec_3)).to be_falsey
      end

    end # context 'user does NOT have an approved application'

  end


  it '.mailer_method' do
    expect(described_class.mailer_method).to eq :membership_payment_due
  end

end
