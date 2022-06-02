require 'rails_helper'

module Reqs
  RSpec.describe CoInfoCompleteReqs do

    let(:subject) { Reqs::CoInfoCompleteReqs }


    describe '.requirements_met?' do

      context 'company name is not blank and address region not nil' do

        it 'one address: true' do
          new_co = create(:company, region: create(:region))
          expect(subject.requirements_met?({ entity: new_co })).to be_truthy
        end

        it '3 addresses (all with Regions): true' do
          new_co = create(:company, num_addresses: 3, region: create(:region))
          expect(subject.requirements_met?({ entity: new_co })).to be_truthy
        end

      end

      it 'company name is blank: false' do
        new_co = create(:company, region: create(:region))
        new_co.name = ''
        expect(subject.requirements_met?({ entity: new_co })).to be_falsey
      end

      it 'one of the addresses has a region that is nil: false' do
        new_co = create(:company, num_addresses: 3, region: create(:region))
        new_co.addresses.last.region = nil
        expect(subject.requirements_met?({ entity: new_co })).to be_falsey
      end
    end

    describe '.missing_info' do

      describe 'validates the arguments' do

        it 'raise ArgumentError if arguments are not correct' do
          expect { subject.missing_info({ this: 'that' }) }.to raise_error(ArgumentError)
        end
      end

      context 'company name is blank' do
        it 'adds activerecord.attributes.company.name to the list of results' do
          co_no_name = build(:company)
          co_no_name.name = ''

          expect(subject.missing_info(entity: co_no_name)).to match_array([I18n.t('activerecord.attributes.company.name')])
        end
      end

      context 'region is blank' do
        it 'adds activerecord.attributes.address.region to the list of results' do
          co_no_region = build(:company)
          co_no_region.addresses.first.region = nil

          expect(subject.missing_info(entity: co_no_region)).to match_array([I18n.t('activerecord.attributes.address.region')])
        end
      end

      context 'no information is missing' do
        it 'returns an empty list' do
          expect(subject.missing_info(entity: build(:company))).to be_empty
        end
      end
    end
  end
end
