require 'rails_helper'
require 'aasm/rspec'

RSpec.shared_examples 'not accepted states' do |states, expected_result|

  it "states should not be #is_accepted" do
    states.each do |state|
      subject.state = state
      expect(subject.is_accepted?).to eq expected_result
    end
  end
end


RSpec.describe MembershipApplication, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:membership_application)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :first_name }
    it { is_expected.to have_db_column :last_name }
    it { is_expected.to have_db_column :company_number }
    it { is_expected.to have_db_column :phone_number }
    it { is_expected.to have_db_column :contact_email }
    it { is_expected.to have_db_column :membership_number }
    it { is_expected.to have_db_column :state }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :contact_email }
    it { is_expected.to validate_presence_of :company_number }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :state }

    it { is_expected.to allow_value('user@example.com').for(:contact_email) }
    it { is_expected.not_to allow_value('userexample.com').for(:contact_email) }

    it { is_expected.to validate_length_of(:company_number).is_equal_to(10) }
  end

  describe 'Validate Swedish Orgnr' do
    let (:company) do
      create(:membership_application)
    end

    subject { company }

    before do
      company.company_number = 1234567890
    end

    it { should_not be_valid }
  end

  describe 'Associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_and_belong_to_many :business_categories }
    it { is_expected.to belong_to :company }
  end

  describe "Uploaded Files" do

    let(:application_owner) { create(:user, email: 'user_1@random.com') }
    let(:application_owner2) { create(:user, email: 'user_2@random.com') }

    it 'uploading a file increases the number of uploaded files by 1' do
      expect { create(:membership_application, user: application_owner, uploaded_files: [ create(:uploaded_file, actual_file: (File.new(File.join(FIXTURE_DIR, 'image.jpg'))) ) ]) }.to change(UploadedFile, :count).by(1)
    end

  end


  describe '#is_accepted?' do
    let!(:states) { MembershipApplication.aasm.states.map(&:name) }
    let(:states_not_accepted) { states.reject { |s| s == :accepted } }


    it_should_behave_like 'not accepted states', MembershipApplication.aasm.states.map(&:name).reject { |s| s == :accepted }, false

    it "state :accepted == is_accepted" do
      subject.state = :accepted
      expect(subject.is_accepted?).to be_truthy
    end

  end


  describe 'test factories' do

    it '1 category with default category name' do
      member_app = create(:membership_application, num_categories: 1)
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name)
        .to eq("Business Category"),
        "The first category name should have been 'Business Category'" \
        "but instead was '#{member_app.business_categories.first.name}'"
    end

    it '2 categories with sequence names' do
      member_app = create(:membership_application, num_categories: 2)
      expect(member_app.business_categories.count).to eq(2), "The number of categories should have been 2 but instead was #{member_app.business_categories.count}"
      expect(member_app.business_categories.first.name).to eq("Business Category 1"), "The first category name should have been 'Business Category 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Business Category 2"), "The last category name should have been 'Business Category 2' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '1 category with the name "Special"' do
      member_app = create(:membership_application, num_categories: 1,
                          category_name: "Special")
      expect(member_app.business_categories.count).to eq(1)
      expect(member_app.business_categories.first.name).to eq("Special"), "The first category name should have been 'Special' but instead was '#{member_app.business_categories.first.name}'"
    end

    it '3 categories with the name "Special 1, Special 2, Special 3"' do
      member_app = create(:membership_application, category_name: "Special", num_categories: 3)
      expect(member_app.business_categories.count).to eq(3)
      expect(member_app.business_categories.first.name).to eq("Special 1"), "The first category name should have been 'Special 1' but instead was '#{member_app.business_categories.first.name}'"
      expect(member_app.business_categories.last.name).to eq("Special 3"), "The first category name should have been 'Special 3' but instead was '#{member_app.business_categories.last.name}'"
    end


  end


  describe 'states, events, and transitions' do

    # expect(job).to have_state(:running)
    # expect(job).to allow_event :run
    # expect(job).to allow_transition_to(:running)
    # expect(job).to transition_from(:sleeping).to(:running).on_event(:run)

    let!(:user) {create(:user_with_membership_app)}

    it 'initial state = under_review' do

      expect(user.membership_application).to have_state(:under_review)
      expect(user.membership_application).not_to have_state(:accepted)
      expect(user.membership_application).not_to have_state(:rejected)
      expect(user.membership_application).not_to have_state(:waiting_for_applicant)
    end


    describe 'state under_review' do

      it 'under_review to rejected on event reject' do
        expect(user.membership_application).to allow_transition_to(:rejected)
        expect(user.membership_application).to transition_from(:under_review).to(:rejected).on_event(:reject)
      end

      it 'under_review to accepted on event accept' do
        expect(user.membership_application).to allow_transition_to(:accepted)
        expect(user.membership_application).to transition_from(:under_review).to(:accepted).on_event(:accept)
      end

      it 'under_review to waiting_for_applicant on event ask_applicant_for_info' do
        expect(user.membership_application).to allow_transition_to(:waiting_for_applicant)
        expect(user.membership_application).to transition_from(:under_review).to(:waiting_for_applicant).on_event(:ask_applicant_for_info)
      end

      it 'under_review to under_review on event applicant_updated_info' do
        expect(user.membership_application).not_to allow_transition_to(:under_review)
      end

    end


    describe 'state waiting_for_applicant' do

      let(:waiting_app) { m = user.membership_application
                          m.ask_applicant_for_info
                          m }

      it 'waiting_for_applicant to rejected on event reject' do
        expect(waiting_app).not_to allow_transition_to(:rejected)
      end

      it 'waiting_for_applicant cannot go to accepted' do
        expect(waiting_app).not_to allow_transition_to(:accepted)
      end

      it 'waiting_for_applicant cannot go to waiting_for_applicant' do
        expect(waiting_app).not_to allow_transition_to(:waiting_for_applicant)
      end

      it 'waiting_for_applicant to under_review on event applicant_updated_info' do
        expect(waiting_app).to allow_transition_to(:under_review)
        expect(waiting_app).to transition_from(:waiting_for_applicant).to(:under_review).on_event(:applicant_updated_info)
      end
    end


    describe 'state accepted' do

      let(:accepted) { m = user.membership_application
                       m.accept
                       m}

      it 'accepted can go to rejected' do
        expect(accepted).to allow_transition_to(:rejected)
        expect(accepted).to transition_from(:accepted).to(:rejected).on_event(:reject)
      end

      it 'accepted cannot go to accepted' do
        expect(accepted).not_to allow_transition_to(:accepted)
      end

      it 'accepted cannot go to waiting_for_applicant ' do
        expect(accepted).not_to allow_transition_to(:waiting_for_applicant)
      end

      it 'accepted cannot go to under_review' do
        expect(accepted).not_to allow_transition_to(:under_review)
      end
    end


    describe 'state rejected' do

      let(:rejected) { m = user.membership_application
                       m.reject
                       m}

      it 'rejected cannot go to rejected' do
        expect(rejected).not_to allow_transition_to(:rejected)
      end

      it 'rejected can go to accepted on event accept' do
        expect(rejected).to allow_transition_to(:accepted)
        expect(rejected).to transition_from(:rejected).to(:accepted).on_event(:accept)
      end

      it 'rejected to waiting_for_applicant on event ask_applicant_for_info' do
        expect(rejected).not_to allow_transition_to(:waiting_for_applicant)
      end

      it 'rejected to under_review on applicant_updated_info on event applicant_updated_info' do
        expect(rejected).not_to allow_transition_to(:under_review)
      end
    end

  end

end
