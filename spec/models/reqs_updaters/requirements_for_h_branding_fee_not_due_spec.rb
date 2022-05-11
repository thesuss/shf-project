require 'rails_helper'

RSpec.describe RequirementsForHBrandingFeeNotDue, type: :model do

  let(:subject) { RequirementsForHBrandingFeeNotDue }

  it '.opposite_class' do
    expect(subject.opposite_class).to eq RequirementsForHBrandingFeeDue
  end


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

    around(:each) do |example|
      Timecop.freeze(jan_2) do
        example.run
      end
    end


    context 'company does not have current members - is always false' do

      it 'is true (fee is not due)' do
        expect(subject.requirements_met?({ company: create(:company) })).to be_truthy
      end
    end


    context 'company has current members' do
      let(:paid_membership_only) { create(:member, first_day: jan_1, membership_status: :current_member) }
      let(:paid_member_co) { paid_membership_only.companies.first }


      context 'branding fee not paid' do
        it 'is false (fee is due)' do
          paid_membership_only
          expect(subject.requirements_met?({ company: paid_member_co })).to be_falsey
        end
      end


      context 'branding fee paid ' do

        context 'branding fee has not expired (is current)' do

          it 'is true (fee is not due)' do
            create(:h_branding_fee_payment,
                   :successful,
                   user:        paid_membership_only,
                   company:     paid_member_co,
                   start_date:  jan_1,
                   expire_date: User.expire_date_for_start_date(jan_1))

            expect(subject.requirements_met?({ company: paid_member_co })).to be_truthy
          end
        end # context 'branding fee has not expired'


        context 'branding fee has expired' do

          it 'is false (fee is due)' do
            create(:h_branding_fee_payment,
                   :successful,
                   user:        paid_membership_only,
                   company:     paid_member_co,
                   start_date:  jan_2 - 500,
                   expire_date: User.expire_date_for_start_date(jan_2 - 500))

            expect(subject.requirements_met?({ company: paid_member_co })).to be_falsey
          end
        end # context 'branding fee has expired'
      end # 'branding fee paid'

    end #  context 'company has current members'

  end # describe '.requirements_met?'

end
