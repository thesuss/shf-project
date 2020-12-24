require 'rails_helper'

require 'shared_context/users'

RSpec.describe RequirementsForRevokingMembership, type: :model do

  include_context 'create users'

  let(:subject) { RequirementsForRevokingMembership }


  describe '.has_expected_arguments?' do

    it 'args has expected :user key' do
      expect(subject.has_expected_arguments?({ user: 'some user' })).to be_truthy
    end

    it 'args does not have expected :user key' do
      expect(subject.has_expected_arguments?({ not_user: 'not some user' })).to be_falsey
    end

    it 'args is nil' do
      expect(subject.has_expected_arguments?(nil)).to be_falsey
    end
  end


  describe '.requirements_met?' do

    it 'user.member? == true and payment NOT expired' do
      expect(subject.requirements_met?({user: member_paid_up})).to be_falsey
    end

    it 'user.member? == false' do
      expect(subject.requirements_met?({user: user})).to be_falsey
    end

    it 'user.member == true but payment has expired' do
      expect(subject.requirements_met?({user: member_expired})).to be_truthy
    end

  end
end
