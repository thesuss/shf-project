require 'rails_helper'

RSpec.describe Memberships::RenewMembershipActions do

  it 'mailer class is MemberMailer' do
    expect(described_class.mailer_class).to eq ::MemberMailer
  end

  it 'mailer method is membership_renewed' do
    expect(described_class.mailer_method).to eq :membership_renewed
  end

  it '.log_message_success is Membership renewed' do
    expect(described_class.log_message_success).to eq('Membership renewed')
  end
end
