require 'rails_helper'


describe MembershipApplicationPolicy do

  describe 'policy for the status attribute' do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:admin) { create(:user, email: 'admin@sgf.com', admin: true) }
    let(:not_the_owner) { create(:user, email: 'user_2@random.com') }

    let(:application) { create(:membership_application,
                               user: application_owner) }


    describe 'For the MembershipApplication creator' do

      subject { described_class.new(application_owner, application) }

      it 'can show the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:show)
      end

      it 'can create a status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end

      it 'cannot edit the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:edit)
      end

      it 'cannot update the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:update)
      end

      it 'cannot destroy the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:destroy)
      end

    end


    describe 'for user not the owner' do
      subject { described_class.new(not_the_owner, application) }

      it 'can show the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:show)
      end

      it 'can create a status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end

      it 'cannot edit the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:edit)
      end

      it 'cannot update the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:update)
      end

      it 'cannot destroy the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:destroy)
      end
    end


    describe 'for a visitor' do
      subject { described_class.new(nil, application) }

      it 'can create a status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end

      it 'cannot edit the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:edit)
      end
      it 'cannot update the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:update)
      end
      it 'cannot destroy the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:destroy)
      end

      it 'cannot see (show) the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:show)
      end
    end

    describe 'For admins' do
      subject { described_class.new(admin, application) }

      it 'can show the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:show)
      end

      it 'can create a status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end

      it 'can do all actions with #status' do
        is_expected.to permit_mass_assignment_of(:status)
      end

      it 'can edit the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:edit)
      end

      it 'can update the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:update)
      end

      it 'can destroy the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:destroy)
      end
    end

  end
end