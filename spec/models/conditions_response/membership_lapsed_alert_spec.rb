require 'rails_helper'

RSpec.describe MembershipLapsedAlert, type: :model do

  let(:dec_1_2018)  { Date.new(2018, 12,  1) }
  let(:dec_2_2018)  { Date.new(2018, 12,  2) }
  let(:dec_3_2018)  { Date.new(2018, 12,  3) }
  let(:dec_5_2018)  { Date.new(2018, 12,  5) }

  let(:dec_1_2017) { Date.new(2017, 12, 1) }

  let(:user) { create(:user) }

  let(:condition) { create(:condition, timing: MembershipLapsedAlert::TIMING_AFTER, config: { days: [1, 3, 5]} ) }
  let(:config) { { days: [1, 3, 5] } }
  let(:timing) { MembershipLapsedAlert::TIMING_AFTER }


  describe '.send_alert_this_day?(config, user)' do

    it 'RequirementsForMembershipLapsed is not satisfied' do
      allow(RequirementsForMembershipLapsed).to receive(:requirements_met?).and_return(false)

      expect(described_class.instance.send_alert_this_day?(timing, config, user)).to be_falsey
    end


    context 'RequirementsForMembershipLapsed is satisfied' do

      let(:membership_app) do
        app = create(:shf_application, :accepted)
        app.update(created_at: dec_1_2017)
        app
      end

      let(:former_member) { membership_app.user }

      def create_expired_payment
        create(:payment, :successful, user: former_member,
               payment_type: Payment::PAYMENT_TYPE_MEMBER,
               start_date: dec_1_2017,
               expire_date: User.expire_date_for_start_date(dec_1_2017))
      end

      it 'false when the day is not in the config list of days to send the alert' do
        create_expired_payment
        Timecop.freeze(dec_2_2018) do
          expect(described_class.instance.send_alert_this_day?(timing, config, former_member)).to be_falsey
        end
      end

      it 'true when the day is in the config list of days to send the alert' do
        create_expired_payment
        listed_days = [dec_1_2018, dec_3_2018, dec_5_2018]
        listed_days.each do | alert_day |
          Timecop.freeze(alert_day) do
            expect(described_class.instance.send_alert_this_day?(timing, config, former_member)).to be_truthy
          end
        end
      end

    end

  end


  it '.mailer_method' do
    expect(described_class.instance.mailer_method).to eq :membership_lapsed
  end

end
