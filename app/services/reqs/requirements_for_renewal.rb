# frozen_string_literal: true

require_relative 'renewal_with_fail_info'

module Reqs

  #--------------------------
  #
  # @class RequirementsForRenewal
  #
  # @responsibility Knows what the requirements are for a Member to renew membership.
  #
  #   Given a member, it can respond true or false if the membership renewal requirements are met.
  #   Note that it is _not_ the responsibility of this class to know if the given member has been
  #   unpaid so long that they cannot simply 'renew' but must re-apply.
  #
  #  This is a very simple class because the requirements are currently very simple.
  #  The importance is that
  #   IT IS THE ONLY PLACE THAT CODE NEEDS TO BE TOUCHED IF MEMBERSHIP REQUIREMENTS ARE CHANGED.
  #
  #  Only 1 is needed for the system.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/08/20
  #
  #--------------------------

  class RequirementsForRenewal < AbstractReqsForUserMembership

    include RenewalWithFailInfo

    @failed_requirements = []

    # check all requirements except the payment.
    # Wrap each requirement method in record_requirement_failure so we can record the reason why
    # the requirement failed.
    #
    # @return [true, false]
    def self.requirements_excluding_payments_met?(user, date = Date.current)
      reset_failed_requirements

      record_requirement_failure(user, :may_renew?, nil, "cannot renew based on the current membership status (status: #{user.membership_status})") &
        record_requirement_failure(user, :valid_date_for_renewal?, date, "#{date} is not a valid renewal date (#{current_membership_short_str(user)})") &
        record_requirement_failure(user, :has_approved_shf_application?, nil, "no approved application") &
        record_requirement_failure(self, :agreed_to_membership_terms?, user, "has not agreed to membership terms within the right time period (#{most_recent_membership_short_str(user)}; #{current_membership_short_str(user)}; last agreed to: #{UserChecklistManager.most_recent_membership_guidelines_list_for(user)&.date_completed})") &
        record_requirement_failure(self, :docs_uploaded?, user, "no uploaded documents within the right time period (#{most_recent_membership_short_str(user)}; #{current_membership_short_str(user)}; most recent upload created_at: #{user.most_recent_uploaded_file&.created_at})")
    end

    # A current member must have uploaded at least 1 document during their current membership.
    # A member in the grace period must have uploaded at least 1 document since their
    # most recent membership expired, even if they uploaded at least 1 document during
    # their most recent membership.  (They have to do it again.)
    #
    # @note We could use subclasses or mixins to handle checking requirements (like uploading docs)
    #   for different membership statuses.  But for now this is simple and clear. Refactoring
    #   and revising can happen later if needed.
    #
    # @param user [User]
    # @return [true,false]
    def self.docs_uploaded?(user)
      case user.membership_status.to_sym
        when User::STATE_CURRENT_MEMBER
          user.file_uploaded_during_this_membership_term?
        when User::STATE_IN_GRACE_PERIOD
          user.file_uploaded_on_or_after?(user.most_recent_membership.last_day + 1.day)
        else
          false
      end
    end

    # Get the list of documents that have been uploaded for renewal.
    # Return an empty list if none have been uploaded.
    # @todo This is a smell: having to check the status yet again.  Should be subclasses or modules/mixins
    #
    # @return [Array<UploadedFile>]
    def self.docs_uploaded_for_renewal(user)
      case user.membership_status.to_sym
        when User::STATE_CURRENT_MEMBER
          user.files_uploaded_during_this_membership
        when User::STATE_IN_GRACE_PERIOD
          user.files_uploaded_on_or_after(user.most_recent_membership.last_day + 1.day)
        else
          []
      end

    end

    # A current member must have agreed to the membership terms since this term begin
    # EXCEPT for the very first membership: they may have agreed to the terms before we implemented
    # membership, in which case they must have agreed to the terms before their current membership ends.
    #
    # A member in the grace period must agree the membership terms since their most recent membership
    # has ended, even if they've agreed to the terms during their membership.
    #
    # @param user [User]
    # @return [true,false]
    def self.agreed_to_membership_terms?(user)
      UserChecklistManager.completed_membership_guidelines_checklist_for_renewal?(user)
    end
  end
end
