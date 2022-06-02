# frozen_string_literal: true

module Memberships

  class MembershipFactoryError < StandardError; end

  #--------------------------
  #
  # @class MembershipFactory
  #
  # @desc Responsibility: create the right class of Membership based on the owner (e.g. CompanyMembership, UserMembership)
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/20/22
  #
  #--------------------------

  class MembershipFactory

    # Instantiate the right class of a membership from the owner based on the class of the owner,
    # and set the owner to the given owner.
    # Raise an error if we cannot create it because the owner is nil or if we cannot find the right membership class based on the owner class
    #
    # @raise [MembershipFactoryError, NameError]
    # @return [AbstractMembership]
    def self.new_for(owner)
      raise MembershipFactoryError, 'Cannot create a membership from a nil owner' unless owner

      # This will raise a NameError if we cannot find the class
      new_membership_class = "#{owner.class}Membership".constantize
      new_membership_class.new(owner: owner)
    end
  end
end
