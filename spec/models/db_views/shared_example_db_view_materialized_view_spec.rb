# frozen_string_literal: true

require 'rails_helper'

# This actually tests the module DbViews::DbViewHasUser
module DbViews
  RSpec.shared_examples 'a materialized view' do

    it 'can be refreshed' do
      expect(described_class.public_methods.include?(:refresh)).to be_truthy
    end

    it 'is a db materialized view' do
      expect(subject).to be_a_kind_of(AbstractDbMaterializedView)
    end

    it 'is read only (cannot be saved)' do
      expect(subject.readonly?).to be_truthy
    end
  end
end
