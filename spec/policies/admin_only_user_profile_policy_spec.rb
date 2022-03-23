require 'rails_helper'

RSpec.describe AdminOnly::UserProfilePolicy do

  let(:user_1) { create(:user, email: 'user@random.com') }
  let(:member) { create(:member_with_membership_app, email: 'member@random.com', company_number: '5562728336')}
  let(:admin)  { create(:user, email: 'admin@shf.com', admin: true) }
  let(:visitor) { build(:visitor) }

  CONTROLLER_ACTIONS = [:edit, :update, :become]

  describe 'Admin is permitted everything' do

    subject { described_class.new(admin, nil) }

    CONTROLLER_ACTIONS.each do | action |
      it { is_expected.to permit_action action }
    end
  end


  describe 'Member is forbidden everything' do
    subject { described_class.new(member, nil) }

    CONTROLLER_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end
  end


  describe 'User (logged in) is forbidden everything' do
    subject { described_class.new(user_1, nil) }

    CONTROLLER_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end
  end

  describe 'Visitor (not logged in) is forbidden everything' do
    subject { described_class.new(visitor, nil) }

    CONTROLLER_ACTIONS.each do | action |
      it { is_expected.to forbid_action action }
    end
  end


end
