# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_example_db_view_materialized_view_spec'

module DbViews
  RSpec.describe CompanyAndMember, type: :model do

    it_behaves_like 'a materialized view'
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:member).with_foreign_key("user_id") }


    describe 'is all companies with current members', skip: true do
      # The materialized view is not being populated with refresh.  Others have reported this problem.
      #   It does populate in :development.  It may have something to do with the structure.sql

      xit 'only companies with current members' do
        pending
      end

      xit 'each company is listed 1 time for each current member' do
        pending 'get the count of companies based on the number of current members for it?'
      end
    end

    describe 'is all current members with their companies', skip: true do
      # The materialized view is not being populated with refresh.  Others have reported this problem.
      #   It does populate in :development.  It may have something to do with the structure.sql

      xit 'only gets current members' do
        pending
      end

      xit 'each current member also has the company' do
        pending
      end
    end
  end
end
