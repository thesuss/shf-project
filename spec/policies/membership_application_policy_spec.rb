require 'rails_helper'


describe MembershipApplicationPolicy do

  shared_examples_for 'cannot change or destroy status' do
    describe 'cannot edit, update, or destroy status' do
      subject { described_class.new(this_user, this_application) }

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
  end

  shared_examples_for 'can create status' do
    describe 'can create status' do
      subject { described_class.new(this_user, this_application) }
      it 'can create a status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end
    end
  end

  shared_examples_for 'can see the status' do
    describe 'can show status' do
      subject { described_class.new(this_user, this_application) }
      it 'can show the status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:show)
      end
    end
  end


  describe 'policy for the status attribute' do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:admin) { create(:user, email: 'admin@sgf.com', admin: true) }
    let(:not_the_owner) { create(:user, email: 'user_2@random.com') }

    let(:application) { create(:membership_application,
                               user: application_owner) }


    describe 'For the MembershipApplication creator' do
      it_behaves_like 'can see the status' do
        let(:this_application) { application }
        let(:this_user) { application_owner }
      end

      it_behaves_like 'can create status' do
        let(:this_application) { application }
        let(:this_user) { application_owner }
      end

      it_behaves_like 'cannot change or destroy status' do
        let(:this_application) { application }
        let(:this_user) { application_owner }
      end
    end

    describe 'for user not the owner' do
      subject { described_class.new(not_the_owner, application) }

      it_behaves_like 'can see the status' do
        let(:this_application) { application }
        let(:this_user) { not_the_owner }
      end

      it_behaves_like 'can create status' do
        let(:this_application) { application }
        let(:this_user) { not_the_owner }
      end

      it_behaves_like 'cannot change or destroy status' do
        let(:this_application) { application }
        let(:this_user) { not_the_owner }
      end
    end

    describe 'for a visitor' do
      subject { described_class.new(nil, application) }

      it 'can create #status' do
        is_expected.to permit_mass_assignment_of(:status).for_action(:create)
      end

      it_behaves_like 'cannot change or destroy status' do
        let(:this_application) { application }
        let(:this_user) { nil }
      end

      it 'cannot see (show) the status' do
        is_expected.to forbid_mass_assignment_of(:status).for_action(:show)
      end
    end

    describe 'For admins' do
      subject { described_class.new(admin, application) }

      it_behaves_like 'can see the status' do
        let(:this_application) { application }
        let(:this_user) { admin }
      end

      it_behaves_like 'can create status' do
        let(:this_application) { application }
        let(:this_user) { admin }
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