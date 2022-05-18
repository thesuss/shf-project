# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_example_db_view_materialized_view_spec'

module DbViews
  RSpec.describe MemberAndCategory, type: :model, no_db_cleaner: true do

    it_behaves_like 'a materialized view'

    it { is_expected.to belong_to(:member).with_foreign_key("user_id") }
    it { is_expected.to belong_to(:business_category).with_foreign_key('category_id') }
    it { is_expected.to belong_to(:application).with_foreign_key('application_id') }


    describe 'it is all current members with their categories', skip: true do
      # The materialized view is not being populated with refresh.  Others have reported this problem.
      #   It does populate in :development.  It may have something to do with the structure.sql

      xit 'each is a current member and a category for the member' do
        described_class.refresh # populate the materialized view
        expect(described_class.count).to eq 0

        create(:member)

        described_class.refresh # populate the materialized view
        expect(described_class.count).to eq 1

        member_and_category = described_class.first
        expect(member_and_category.member).to be_a_current_member
      end
    end
  end
end
