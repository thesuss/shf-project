# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # AbstractReqsForMember
  #
  # @responsibility Checks if requirements are met in 2 parts: non-payment related and payment related.
  # Subclasses MUST define these methods:
  #   - requirements_excluding_payments_met?
  #   - payment_requirements_met?
  #
  #
  # @todo fix the ugly pattern of calling these classes of:  self.<method>(entity: self). blech. Ex: User  user.requirements_for_user.requirements_excluding_payments_met?(user, ....)
  #   make these instance methods so we can initialize with the entity?
  #
  # @todo This is not a good name. It does not communicate anything about the responsibility
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/23/17
  #
  #--------------------------

  class AbstractReqsForMember < AbstractRequirements

    def self.requirements_met?(args)
      date = args.fetch(:date, nil).nil? ? Date.current : args[:date] # corrects if nil is explicitly passed in
      entity = args.fetch(:entity)
      requirements_excluding_payments_met?(entity, date) &&
        payment_requirements_met?(entity, date)
    end

    # Subclasses MUST override this
    def self.requirements_excluding_payments_met?(*)
      raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
    end

    # Subclasses MUST override this
    def self.payment_requirements_met?(*)
      raise NoMethodError, "Subclass must define the #{__method__} method and return true or false", caller
    end
  end
end
