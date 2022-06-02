# frozen_string_literal: true

module Memberships

  class ArchivedMembershipFactoryError < StandardError; end

  #--------------------------
  #
  # @class ArchivedMembershipFactory
  #
  # @desc Responsibility: create the right class of an archived membership based on the class of the membership (e.g. ArchivedCompanyMembership, ArchivedUserMembership)
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   5/20/22
  #
  #--------------------------

  class ArchivedMembershipFactory

    # Instantiate the right class of a membership from the owner based on the class of the owner,
    # and set the owner to the given owner.
    # Raise an error if we cannot create it because the owner is nil or if we cannot find the right membership class based on the owner class
    #
    # @raise [ArchivedMembershipFactoryError, NameError]
    # @return [AbstractMembership]
    def self.create_from(membership)
      raise ArchivedMembershipFactoryError, 'Cannot create an archived membership from a nil membership' unless membership

      # This will raise a NameError if we cannot find the class
      new_archived_membership_class = "Archived#{membership.owner.class}Membership".constantize
      new_archived_membership_class.create_from(membership)
    end
  end
end
