# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # AbstractReqsForMembership
  #
  # @responsibility Knows what the membership requirements are for something that IsMember
  #   Given an entity, it can respond true or false if membership requirements are met.
  #
  # This is a very simple class because the requirements are currently very simple.
  # The importance is that
  #  IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
  #
  # Only 1 is needed for the system.
  #
  # @todo fix the ugly pattern of calling these classes of:  self.<method>(entity: self). blech. Ex: User  user.requirements_for_user.requirements_excluding_payments_met?(user, ....)
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/23/17
  #
  #--------------------------

  class AbstractReqsForMembership < AbstractReqsForMember

    def self.requirements_met?(args)
      entity = args[:entity]
      date = args.fetch(:date, nil).nil? ? Date.current : args[:date] # corrects if nil is explicitly passed in
      requirements_excluding_payments_met?(entity, date) &&
        payment_requirements_met?(entity, date)
    end

    def self.requirements_excluding_payments_met?(_entity, _date = Date.current)
      raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
    end

    # @param [User, Company] entity that checks to see if the payments are current as of the given date
    # @fixme create class Payor and use that as the parameter type
    def self.payment_requirements_met?(entity, date = Date.current)
      entity.payments_current_as_of?(date)
    end
  end
end
