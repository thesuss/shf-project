#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class Adapters::AbstractSchemaOrgAdapter
  #
  # @desc Responsibility: abstract parent class for all Schema.org adapters
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-02-19
  #
  # @file company_to_schema_org_adapter.rb
  #
  #--------------------------
  class AbstractSchemaOrgAdapter < AbstractAdapter

    # effectively is an alias to :as_target
    def to_schema_org
      as_target
    end

  end

end

