# frozen_string_literal: true

module DbViews
  #--------------------------
  #
  # @class AbstractDbMaterializedView
  #
  # @desc Responsibility: abstract parent class for all db views
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/13/22
  #
  # @todo Should all DB Views be in their own namespace? What advantage does it really provide? Do they need to be dealt with any differently than other models mapped to the database?
  #   - they are refreshed (updated) differently, but other than that, what is the difference?
  #
  #--------------------------
  class AbstractDbMaterializedView < ApplicationRecord

    self.abstract_class = true

    # Refresh the materialized view
    def self.refresh
      Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
    end

    # From the scenic gem:
    # this isn't strictly necessary, but it will prevent
    # rails from calling save, which would fail anyway.
    def readonly?
      true
    end
  end
end

