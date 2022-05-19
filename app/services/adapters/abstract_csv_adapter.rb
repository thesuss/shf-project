#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class AbstractCsvAdapter
  #
  # @desc Responsibility: Common behavior and info for adapting an object to a CSV representation.
  #  "CSV" = comma separated value text
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-02-20
  #
  #
  #--------------------------
  class AbstractCsvAdapter < AbstractAdapter


    def target_class
      CsvRow
    end


    # surround the item with double quotes ("")
    def quote(item)
      "\"#{item}\""
    end


    # subclasses should override and do whatever they need to do with the @adaptee to
    # produce a CSV representation.
    #
    def set_target_attributes(target)
      target
    end


    # Subclasses should override this and produce a string that can be used
    # as a header row in a CSV file.
    #
    # @return [String] - a string of comma separated headers.
    #
    def self.header_str(*args)
      create_header_str(headers(args))
    end


    def self.headers(*args)
      []
    end


    # ==================================================================================

    protected

    def self.create_header_str(header_entries)
      out_str = '' # is this stmt needed?

      out_str << header_entries.map { |header_str| "'#{header_str.strip}'" }.join(',')

      out_str << "\n"
    end

  end

end
