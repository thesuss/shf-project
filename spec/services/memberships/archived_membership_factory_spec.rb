require 'rails_helper'

module Memberships
  RSpec.describe ArchivedMembershipFactory do

    it 'the instantiated class is based on the membership owner class' do
      user_membership = create(:membership) # have to use create: so that the owner (a User) is instantiated and not nil
      expect(described_class.create_from(user_membership)).to be_a ArchivedUserMembership
      company_membership = create(:company_membership)
      company_membership.owner = create(:company)
      expect(described_class.create_from(company_membership)).to be_a ArchivedCompanyMembership
    end

    it 'raises an ArchivedMembershipFactoryError if the membership is nil' do
      expect{described_class.create_from(nil)}.to raise_error(ArchivedMembershipFactoryError, "Cannot create an archived membership from a nil membership")
    end

    it 'raises a NameError if it cannot create an Archived class based on the membership owner type' do
      bad_membership = create(:membership)
      bad_membership.owner = create(:address, addressable: create(:user))
      expect{described_class.create_from(bad_membership)}.to raise_error(NameError)
    end
  end
end
