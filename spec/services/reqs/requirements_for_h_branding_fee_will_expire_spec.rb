require 'rails_helper'

module Reqs
  RSpec.describe RequirementsForHBrandingFeeWillExpire do
    let(:subject) { Reqs::RequirementsForHBrandingFeeWillExpire }

    describe '.has_expected_arguments?' do

      it 'args has expected :company key' do
        expect(subject.has_expected_arguments?({ company: 'some co' })).to be_truthy
      end

      it 'args does not have expected :company key' do
        expect(subject.has_expected_arguments?({ not_co: 'not some co' })).to be_falsey
      end

      it 'args is nil' do
        expect(subject.has_expected_arguments?(nil)).to be_falsey
      end
    end

    describe '.requirements_met?' do

      let(:jan_1) { Date.new(2019, 1, 1) }
      let(:jan_2) { Date.new(2019, 1, 2) }
      let(:jan_2_500_days_ago) { jan_2 - 500.days }

      let(:june_19) { Date.new(2019, 6, 19) }

      let(:jan_5_2020) { Date.new(2020, 1, 5) }

      around(:each) do |example|
        travel_to(jan_2) do
          example.run
        end
      end

      context 'company does not have current members - is always false' do

        it 'is false (no fee due)' do
          co = build(:company)
          allow(co).to receive(:current_members).and_return([])
          expect(subject.requirements_met?({ company: co })).to be_falsey
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
          it 'is false' do
            expect(subject.requirements_met?({ company: paid_member_co })).to be_falsey
          end
        end

        context 'branding fee paid ' do
          context 'branding fee has not expired (is current)' do

            it 'is true (will be due)' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_1,
                     expire_date: Company.expire_date_for_start_date(jan_1))
              expect(subject.requirements_met?({ company: paid_member_co })).to be_truthy
            end
          end

          context 'branding fee has expired' do

            it 'is false' do
              create(:h_branding_fee_payment,
                     :successful,
                     user: paid_membership_only,
                     company: paid_member_co,
                     start_date: jan_2_500_days_ago,
                     expire_date: Company.expire_date_for_start_date(jan_2_500_days_ago))

              expect(subject.requirements_met?({ company: paid_member_co })).to be_falsey
            end
          end

        end # 'branding fee paid'

      end #  context 'company has current members'

      context 'does not have current members' do

        let(:membership_expired) {
          member = create(:member, first_day: jan_1)
          create(:membership_fee_payment,
                 :successful,
                 user: member,
                 start_date: jan_1,
                 expire_date: User.expire_date_for_start_date(jan_1))
          create(:h_branding_fee_payment,
                 :successful,
                 user: member,
                 company: member.companies.first,
                 start_date: june_19,
                 expire_date: Company.expire_date_for_start_date(june_19))
          member
        }

        let(:co_memberships_expired) do
          co = membership_expired.companies.first
          allow(co).to receive(:current_members).and_return([])
          co
        end

        it 'is false' do
          expect(subject.requirements_met?({ company: co_memberships_expired })).to be_falsey
        end
      end

    end
  end
end
