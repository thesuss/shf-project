require 'rails_helper'

module Reqs
  RSpec.describe CompanyMembershipReqs do
    let(:subject) { Reqs::CompanyMembershipReqs }
    let(:company) { build(:company) }
    let(:yesterday) { Date.current - 1.day }

    describe '.requirements_excluding_payments_met?' do

      context 'company may start a new membership?' do
        before(:each) { allow(company).to receive(:may_start_membership?).and_return(true) }

        it 'true company information is complete' do
          allow(company).to receive(:information_complete?).and_return(true)
          expect(subject.requirements_excluding_payments_met?(company)).to be_truthy
        end

        it 'false if company information is not complete' do
          allow(company).to receive(:information_complete?).and_return(false)
          expect(subject.requirements_excluding_payments_met?(company)).to be_falsey
        end
      end

      it 'false if company may not start a new membership' do
        allow(company).to receive(:may_start_membership?).and_return(false)
        expect(subject.requirements_excluding_payments_met?(company)).to be_falsey
      end
    end

    # TODO: Are all of these integration tests needed?  Can things be mocked/stubbed?
    describe 'Integration tests' do
      let(:member) { create(:member_with_membership_app) }

      let(:member_expired_payment) do
        create(:membership_fee_payment,
               :successful,
               company: member,
               start_date: Time.zone.today - 1.year - 1.month,
               expire_date: Time.zone.today - 1.year)
      end

      let(:member_current_payment) do
        start_date, expire_date = User.next_membership_payment_dates(member.id)
        create(:membership_fee_payment,
               :successful,
               company: member,
               start_date: start_date,
               expire_date: expire_date)
      end

      describe '.requirements_met?' do

        context 'company may start a new membership?' do

          context 'company information is complete' do

            it 'true if membership payment made (and it has not expired)' do
              co_paid_up = create(:company)
              allow(co_paid_up).to receive(:may_start_membership?).and_return(true)
              allow(co_paid_up).to receive(:information_complete?).and_return(true)
              expect(subject.requirements_excluding_payments_met?(co_paid_up)).to be_truthy

              start_date, expire_date = co_paid_up.next_membership_payment_dates
              create(:h_branding_fee_payment,
                     :successful,
                     company: co_paid_up,
                     start_date: start_date,
                     expire_date: expire_date)

              expect(subject.requirements_met?({ entity: co_paid_up })).to be_truthy
            end

            it 'false if membership payment made and it HAS expired' do
              co_payments_too_old = create(:company)
              allow(co_payments_too_old).to receive(:may_start_membership?).and_return(true)
              allow(co_payments_too_old).to receive(:information_complete?).and_return(true)
              expect(subject.requirements_excluding_payments_met?(co_payments_too_old)).to be_truthy

              start_date, expire_date = co_payments_too_old.next_membership_payment_dates
              create(:h_branding_fee_payment,
                     :successful,
                     company: co_payments_too_old,
                     start_date: start_date,
                     expire_date: expire_date)

              travel_to(expire_date + 1.day) do
                expect(subject.requirements_met?({ entity: co_payments_too_old })).to be_falsey
              end
            end
          end
        end
      end
    end
  end
end

