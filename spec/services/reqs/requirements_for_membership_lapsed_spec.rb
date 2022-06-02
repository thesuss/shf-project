require 'rails_helper'

module Reqs
  RSpec.describe RequirementsForMembershipLapsed do
    let(:subject) { RequirementsForMembershipLapsed }

    describe '.requirements_met?' do

      it 'true if in the grace period' do
        grace_period_member = build(:member, last_day: Date.current - 5.days,
                                    membership_status: :in_grace_period,
                                    member: false,)
        expect(subject.requirements_met?(entity: grace_period_member)).to be_truthy
      end

      it 'true if a former member' do
        former_member = build(:member, last_day: Date.current - 500.days,
                              membership_status: :former_member,
                              member: false,)
        expect(subject.requirements_met?(entity: former_member)).to be_truthy
      end

      describe 'false for any other membership status' do

        it 'current member' do
          expect(subject.requirements_met?(entity: build(:member))).to be_falsey
        end

        it 'not a member' do
          expect(subject.requirements_met?(entity: build(:user))).to be_falsey
        end

        other_membership_statuses = User.membership_statuses -
          [User::STATE_CURRENT_MEMBER, User::STATE_IN_GRACE_PERIOD,
           User::STATE_FORMER_MEMBER, User::STATE_NOT_A_MEMBER]
        other_membership_statuses.each do |other_status|
          it "#{other_status} is false" do
            expect(subject.requirements_met?(entity: build(:user, membership_status: other_status))).to be_falsey
          end
        end

      end

    end
  end
end
