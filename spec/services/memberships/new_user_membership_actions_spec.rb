require 'rails_helper'

RSpec.describe Memberships::NewUserMembershipActions do

  it 'the mailer is MemberMailer' do
    expect(described_class.mailer_class).to eq MemberMailer
  end

  it 'mailer method is :membership_granted' do
    expect(described_class.mailer_method).to eq :membership_granted
  end
end
