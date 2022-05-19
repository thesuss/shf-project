# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # RequirementsForRenewal
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
  # @todo Make this a Singleton so that we don't need to use a class variable to store the failed requirements info
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   12/08/20
  #
  #--------------------------

  class RequirementsForRenewal < AbstractReqsForMembership

    @@failed_requirements = []

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

    # Call the method with the given arguments.
    # If the result is falsey, record the failure
    # @return [true, false] the result from the method
    def self.record_requirement_failure(obj, method, *method_args, failure_string)
      result_boolean = method_args.compact.empty? ? obj.send(method) : obj.send(method, *method_args)
      record_failure(method, failure_string, method_args) unless !!result_boolean
      result_boolean
    end

    # store the failure information in @failed_requirements
    # @todo The result (Success | Failure) should be a Result object (instead of a simple Hash. Then it can respond better.)
    #
    # @return [Array<Hash>] List of hashes, where each Hash has a :string (value = a String that describes what failed)
    #    :method (value = Symbol of the method that failed), and :method_args (value = [String] method_args.inspect (so the string representation is saved, not the objects themselves))
    def self.record_failure(method_name, failure_string, *method_args)
      @@failed_requirements << { method: method_name.to_sym,
                                 string: failure_string,
                                 method_args: method_args.inspect }
    end

    # Get a short info string for the current membership for the given user. Used for debugging and to see if a user can renew.
    # @param [User] user Get the most recent membership for this user
    # @return [String]
    def self.current_membership_short_str(user)
      "curr.mship: #{ short_membership_str(user.current_membership)}"
    end

    # Get a short info string for the most recent membership for the given user.  Used for debugging and to see if a user can renew.
    # @param [User] user Get the most recent membership for this user
    # @return [String]
    def self.most_recent_membership_short_str(user)
      "most recent mship: #{short_membership_str(user.most_recent_membership)}"
    end

    #  Get a short info string for the given membership; shows id, first day and last day. Used for debugging and to see if a membership can be renewed
    # @param [Membership | Nil ] membership The membership to use for the string
    # @return [String] The info string for the membership. Is 'nil' if the membership is nil
    def self.short_membership_str(membership)
      return 'nil' if membership.nil?

      "[#{membership.id}] #{membership.first_day} - #{membership.last_day}"
    end

    # Return a list of why the requirements methods failed.
    # This is a work in progress; this is just an initial idea.
    #
    # @return [Array<Hash>] List of hashes, where each Hash has a :string (value = a String that describes what failed)
    #    :method (value = Symbol of the method that failed), and :method_args (value = list of arguments passed to the method)
    def self.failed_requirements
      @@failed_requirements
    end

    def self.reset_failed_requirements
      @@failed_requirements = []
    end
  end
end
