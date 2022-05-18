# frozen_string_literal: true

require 'rails_helper'
require_relative 'shared_example_db_view_materialized_view_spec'

module DbViews
  RSpec.describe CompanyAndCategory, type: :model do

    it_behaves_like 'a materialized view'
    it { is_expected.to belong_to(:company) }
    it { is_expected.to belong_to(:business_category).with_foreign_key("category_id") }

  end
end
