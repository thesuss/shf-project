require 'rails_helper'

RSpec.describe Memberships::NewRenewMembershipActions do

  let(:mock_email_msg) { instance_double('Mail::Message', deliver: true) }
  let(:new_membership) { build(:membership) }
  let(:given_user) { new_membership.owner }

  describe '.other_keyword_args_valid?' do

    it 'true if has key first_day: and the value is not nil' do
      expect(described_class.other_keyword_args_valid?(first_day: Date.current)).to be_truthy
    end

    it 'false if does not have key first_day: or if value is nil' do
      expect(described_class.other_keyword_args_valid?(first_day: nil)).to be_falsey
      expect(described_class.other_keyword_args_valid?(anything_else: 'blorf')).to be_falsey
      expect(described_class.other_keyword_args_valid?({})).to be_falsey
    end
  end

  describe '.accomplish_actions' do
    it 'creates a new membership for the user, first_day = the given first day' do
      allow(given_user).to receive(:update!)
      expect(described_class).to receive(:create_new_membership).with(given_user, Date.current)
      described_class.accomplish_actions(given_user, send_email: false, first_day: Date.current)
    end

    it 'sets the member attribute to true' do
      expect(described_class).to receive(:set_is_a_member).with(given_user)
      described_class.accomplish_actions(given_user, send_email: false, first_day: Date.current)
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

      it 'sends the mail method to the Mailer with the given entity as the argument' do
        expect(Memberships::NullMailer).to receive(:no_mail_sent).with(given_user)
                                                                 .and_return(mock_email_msg)
        described_class.accomplish_actions(given_user, send_email: true, first_day: Date.current){}
      end
    end
  end

  it '.create_new_membership with the first day = the given first day' do
    allow(given_user).to receive(:update!)

    expect(Membership).to receive(:last_day_from_first).and_return(Date.current + 1.year)
    expect(Membership).to receive(:create!)
                            .with(owner: given_user, first_day: Date.current, last_day: Date.current + 1.year)
                            .and_call_original
    described_class.create_new_membership(given_user, Date.current)
  end

  it '.set_is_a_member sets the member attribute to true for the entity' do
    expect(given_user).to receive(:update!).with(member: true)
    described_class.set_is_a_member(given_user)
  end
end
