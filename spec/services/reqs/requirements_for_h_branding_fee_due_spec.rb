require 'rails_helper'

module Reqs
  RSpec.describe RequirementsForHBrandingFeeDue do
    let(:subject) { Reqs::RequirementsForHBrandingFeeDue }

    describe '.requirements_met?' do

      let(:jan_1) { Date.new(2019, 1, 1) }
      let(:jan_2) { Date.new(2019, 1, 2) }

      around(:each) do |example|
        travel_to(jan_2) do
          example.run
        end
      end

      context 'company does not have current members - is always false' do

        it 'is false (no fee due)' do
          co = build(:company)
          allow(co).to receive(:current_members).and_return([])
          expect(subject.satisfied?({ company: co })).to be_falsey
        end
      end

      context 'company has current members' do
        let(:paid_membership_only) { create(:member, membership_status: :current_member, first_day: jan_1) }
        let(:paid_member_co) do
          co = paid_membership_only.companies.first
          allow(co).to receive(:current_members).and_return([paid_membership_only])
          co
        end

        context 'branding fee not paid' do
          it 'is true (fee is due)' do
            expect(subject.requirements_met?({ entity: paid_member_co })).to be_truthy
          end
        end

        context 'branding fee paid ' do

          context 'branding fee has not expired (is current)' do

            let(:paid_both_current) {
              member = create(:member_with_membership_app)
              create(:membership_fee_payment,
                     :successful,
                     user: member,
                     start_date: jan_1,
                     expire_date: User.expire_date_for_start_date(jan_1))

              member
            }

            it 'is false (no fee due)' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_1,
                     expire_date: User.expire_date_for_start_date(jan_1))

              expect(subject.requirements_met?({ entity: paid_member_co })).to be_falsey
            end
          end

          context 'branding fee has expired' do
            it 'is true (fee is due)' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_2 - 500,
                     expire_date: User.expire_date_for_start_date(jan_2 - 500))

              expect(subject.requirements_met?({ entity: paid_member_co })).to be_truthy
            end
          end
        end # 'branding fee paid'

      end
    end
  end
end
