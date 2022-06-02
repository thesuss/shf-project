require 'rails_helper'

RSpec.describe Memberships::NewMembershipActions do

  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }
  let(:new_membership) { build(:membership) }
  let(:given_user) { new_membership.owner }


  describe '.accomplish_actions' do

    context 'super actions_successful? is true' do
      before(:each) { allow(described_class.superclass).to receive(:accomplish_actions).and_return(true) }

      it 'assigns a new membership number to the entity' do
        expect(described_class).to receive(:assign_membership_number)
        described_class.accomplish_actions(given_user)
      end

      context 'send_email is true' do
        let(:mock_membership) { double('Membership', set_first_and_last_day: true) }
        let(:mock_company) { double('Company') }

        before(:each) do
          allow(given_user).to receive(:update!)
          allow(given_user).to receive(:shf_application).and_return(instance_double('ShfApplication', companies: [mock_company]))
          allow(Memberships::NullMailer).to receive(:no_mail_sent).and_return(mock_email_msg)
          allow(AdminAlerter.instance).to receive(:new_membership_granted).with(given_user, deliver_email: true)
        end

        it 'calls AdminAlerter with the user and deliver_email: the send_email status' do
          expect(AdminAlerter.instance).to receive(:new_membership_granted).with(given_user, deliver_email: true)
                                                                           .and_return(mock_email_msg)
          described_class.for_entity(given_user, send_email: true, first_day: Date.current)
        end
      end
    end

    context 'super actions_successful? is false' do
      before(:each) { allow(described_class.superclass).to receive(:accomplish_actions).and_return(false) }

      it 'is false (and does not try to do anything)' do
        expect(described_class.accomplish_actions(given_user)).to be_falsey
      end
    end
  end

  it '.assign_membership_number updates the entity with the next membership number issued' do
    allow(given_user).to receive(:update!).with(member: true)
    expect(given_user).to receive(:update!).with(membership_number: anything)
    described_class.assign_membership_number(given_user)
  end

  describe '.log_message_success' do
    it 'New membership granted' do
      expect(described_class.log_message_success).to eq('New membership granted')
    end
  end
end
