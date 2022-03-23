require 'rails_helper'

RSpec.describe UserPolicy do

  let(:user)   { create(:user, email: 'user_1@random.com') }
  let(:member) { create(:member_with_membership_app,
                        email: 'member@random.com',
                        company_number: '5562728336') }
  let(:admin)  { create(:user, email: 'admin@sfh.com', admin: true) }
  let(:visitor) { build(:visitor) }

  permissions :index? do
    it 'allows access to admin' do
      expect(UserPolicy).to permit(admin)
    end

    it 'denies access to user' do
      expect(UserPolicy).not_to permit(user)
    end

    it 'denies access to member' do
      expect(UserPolicy).not_to permit(member)
    end

    it 'denies access to visitor' do
      expect(UserPolicy).not_to permit(visitor)
    end
  end

  permissions :show? do
    it 'allows access to admin' do
      expect(UserPolicy).to permit(admin)
    end

    it 'allows access to user' do
      expect(UserPolicy).to permit(user, user)
    end

    it 'denies access to member' do
      expect(UserPolicy).not_to permit(member, user)
    end

    it 'denies access to visitor' do
      expect(UserPolicy).not_to permit(visitor, user)
    end
  end

  permissions :edit_status? do
    it 'allows access to admin' do
      expect(UserPolicy).to permit(admin)
    end

    it 'denies access to user' do
      expect(UserPolicy).not_to permit(user)
    end

    it 'denies access to member' do
      expect(UserPolicy).not_to permit(member)
    end

    it 'denies access to visitor' do
      expect(UserPolicy).not_to permit(visitor)
    end
  end
end
