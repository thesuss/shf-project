require 'rails_helper'

require 'shared_context/users'

RSpec.describe UserChecklistManager do

  include ActiveSupport::Testing::TimeHelpers

  include_context 'create users'


  describe '.completed_membership_guidelines_checklist?' do

    it 'returns nil if there are no lists for the user' do
      expect(described_class.completed_membership_guidelines_checklist?(create(:user))).to be_nil
    end

    it 'calls UserChecklist .all_completed? to determine if it is complete or not' do
      checklist = create(:user_checklist)
      user_for_checklist = checklist.user

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return([checklist])
      expect(checklist).to receive(:all_completed?)

      described_class.completed_membership_guidelines_checklist?(user_for_checklist)
    end
  end


  describe '.membership_guidelines_list_for' do

    it 'returns nil if there are no lists for the user' do
      expect(described_class.membership_guidelines_list_for(create(:user))).to be_nil
    end

    it 'returns the most recently created user checklist' do
      user = create(:user, first_name: 'User', last_name: 'With-Checklists')

      # make 2 and expect the most recently created one to be returned
      travel_to(Time.now - 2.days) do
        create(:user_checklist, user: user, name: 'older list')
      end

      create(:user_checklist, user: user, name: 'more recent list')

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(user.checklists)

      expect(described_class.membership_guidelines_list_for(user)).to eq UserChecklist.find_by(name: 'more recent list')
    end

  end


  describe '.must_complete_membership_guidelines_checklist?' do

    it 'false if today < the date we start requiring the membership guidelines checklist' do
      Timecop.freeze(described_class.membership_guidelines_reqd_start_date - 1.minute) do
        expect(described_class.must_complete_membership_guidelines_checklist?(create(:user))).to be_falsey
      end
    end

    context 'today >= the date we start requiring the membership guidelines checklist' do

      let(:one_minute_after_req_start) { described_class.membership_guidelines_reqd_start_date + 1.minute }

      let(:two_days_before_req_duration_end) { User.expire_date_for_start_date(described_class.membership_guidelines_reqd_start_date) - 2.days }


      it 'user is nil raises an error' do
        expect { described_class.must_complete_membership_guidelines_checklist?(nil) }.to raise_error ArgumentError
      end

      it 'true if user is not a current member' do

        travel_to(one_minute_after_req_start) do
          users_not_members = [create(:user), user_no_payments, member_expired, user_all_paid_membership_not_granted]
          users_not_members.each do |not_a_member|
            expect(described_class.must_complete_membership_guidelines_checklist?(not_a_member)).to be_truthy
          end
        end

      end


      context 'current member' do

        context 'expires BEFORE the (Requirement start + 1 term) [ < (requirement start date + Membership Term Duration)]' do

          before(:each) { travel_to two_days_before_req_duration_end }
          after(:each) { travel_back }


          it 'true if members expiration < today (would not be a current member!)' do
            user = build(:member_with_membership_app)
            user.payments << create(:expired_membership_fee_payment) # expired yesterday
            user.save!
            expect(user.membership_current?).not_to be_truthy

            expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
          end

          it 'true if member expiration date = today (would not be a current member!)' do
            user = build(:member_with_membership_app)
            user.payments << create(:expired_membership_fee_payment, expire_date: Time.zone.now) # expired yesterday
            user.save!
            expect(user.membership_current?).not_to be_truthy

            expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
          end

          it 'false if member expiration date > today' do
            user = build(:member_with_membership_app)
            user.payments << create(:expired_membership_fee_payment, expire_date: (Time.zone.now + 1.day))
            user.save!
            expect(user.membership_current?).to be_truthy

            expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_falsey
          end

        end


        context 'expires AFTER the (Requirement start + 1 term) [member expiration > (Req. start date + Membership Term Duration)]' do

          let(:start_date_plus_term_duration) { User.expire_date_for_start_date(described_class.membership_guidelines_reqd_start_date) }

          let(:membership_term_expire_date) { start_date_plus_term_duration + 1.month }

          it 'false if they last paid BEFORE the requirement start date' do

            user = build(:member_with_membership_app)

            # make the payments _before_ the requirement went into effect/started:
            #  note that they payment 'expires' (= membership term) AFTER (requirement start date + Membership Term Duration) (perhaps they paid for 2 terms when they paid)
            travel_to described_class.membership_guidelines_reqd_start_date - 1.day do
              user.payments << create(:expired_membership_fee_payment, expire_date: (membership_term_expire_date))
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration + 1.day do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_falsey
            end
          end

          it 'true if they last paid ON the requirement start date' do
            user = build(:member_with_membership_app)

            # make the payments _after_ the requirement went into effect/started:
            #  note that they payment 'expires' (= membership term) AFTER (requirement start date + Membership Term Duration) (perhaps they paid for 2 terms when they paid)
            travel_to described_class.membership_guidelines_reqd_start_date do
              user.payments << create(:expired_membership_fee_payment, expire_date: (membership_term_expire_date))
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration + 1.day do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
            end
          end

          it 'true if they last paid AFTER the requirement start date' do
            user = build(:member_with_membership_app)

            # make the payments _after_ the requirement went into effect/started:
            #  note that they payment 'expires' (= membership term) AFTER (requirement start date + Membership Term Duration) (perhaps they paid for 2 terms when they paid)
            travel_to described_class.membership_guidelines_reqd_start_date + 1.day do
              user.payments << create(:expired_membership_fee_payment, expire_date: membership_term_expire_date)
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration + 1.day do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
            end
          end

        end


        context 'expires ON the (Requirement start + 1 term) [member expiration == (Req. start date + Membership Term Duration)]' do

          let(:start_date_plus_term_duration) { User.expire_date_for_start_date(described_class.membership_guidelines_reqd_start_date) }


          it 'false if they last paid BEFORE the requirement start date' do
            user = build(:member_with_membership_app)

            travel_to described_class.membership_guidelines_reqd_start_date - 1.day do
              user.payments << create(:expired_membership_fee_payment, expire_date: (start_date_plus_term_duration))
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration - 2.days do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_falsey
            end
          end

          it 'true if they last paid ON the requirement start date' do
            user = build(:member_with_membership_app)

            travel_to described_class.membership_guidelines_reqd_start_date do
              user.payments << create(:expired_membership_fee_payment, expire_date: (start_date_plus_term_duration))
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration + 1.day do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
            end
          end

          it 'true if they last paid AFTER the requirement start date' do
            user = build(:member_with_membership_app)

            travel_to described_class.membership_guidelines_reqd_start_date + 1.day do
              user.payments << create(:expired_membership_fee_payment, expire_date: (start_date_plus_term_duration))
            end
            user.save!
            expect(user.membership_current?).to be_truthy

            travel_to start_date_plus_term_duration + 1.day do
              expect(described_class.must_complete_membership_guidelines_checklist?(user)).to be_truthy
            end
          end
        end

      end

    end

  end

end
