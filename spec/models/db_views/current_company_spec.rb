# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_example_db_view_materialized_view_spec'

module DbViews
  RSpec.describe CurrentCompany, type: :model do

    it_behaves_like 'a materialized view'
    it { is_expected.to belong_to(:company) }

    describe 'companies are current', skip: true do
      # The materialized view is not being populated with refresh.  Others have reported this problem.
      #   It does populate in :development.  It may have something to do with the structure.sql

    end
  end
end
