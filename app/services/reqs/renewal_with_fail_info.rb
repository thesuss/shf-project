# frozen_string_literal: true

module Reqs

  #--------------------------
  #
  # @module RenewalWithFailInfo
  #
  # @responsibility Can call a requirement method and record the reason why it requirement failed.
  #   Helpful when trying to understand why a Renewal failed, etc.
  #   Requires that an entity can respond to the following methods:
  #     - :membership_status
  #     - :current_membership
  #     - :most_recent_membership
  #
  #   This is definitely a work in progress. Much of the logic could be abstracted and generalized using meta-programming (so it's not so tightly bound to membership, for example).  Good enough for now. Can refactor when we need to use it more.
  #
  # @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
  # @date   2022-05-20
  #
  #--------------------------

  module RenewalWithFailInfo

    # This is used as a class variable, so each class must set this like so:
    @failed_requirements = []

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Call the method with the given arguments.
      # If the result is falsey, record the failure
      # @return [true, false] the result from the method
      def record_requirement_failure(obj, method, *method_args, failure_string)
        result_boolean = method_args.compact.empty? ? obj.send(method) : obj.send(method, *method_args)
        record_failure(method, failure_string, method_args) unless !!result_boolean
        result_boolean
      end

      # store the failure information in @failed_requirements
      # @todo The result (Success | Failure) should be a Result object (instead of a simple Hash. Then it can respond better.)
      #
      # @return [Array<Hash>] List of hashes, where each Hash has a :string (value = a String that describes what failed)
      #    :method (value = Symbol of the method that failed), and :method_args (value = [String] method_args.inspect (so the string representation is saved, not the objects themselves))
      def record_failure(method_name, failure_string, *method_args)
        failed_requirements << { method: method_name.to_sym,
                                 string: failure_string,
                                 method_args: method_args.inspect }
      end

      # Get a short info string for the current membership for the given entity. Used for debugging and to see if a entity can renew.
      # @param [User] entity Get the most recent membership for this entity
      # @return [String]
      def current_membership_short_str(entity)
        "curr.mship: #{short_membership_str(entity.current_membership)}"
      end

      # Get a short info string for the most recent membership for the given entity.  Used for debugging and to see if a entity can renew.
      # @param [User] entity Get the most recent membership for this entity
      # @return [String]
      def most_recent_membership_short_str(entity)
        "most recent mship: #{short_membership_str(entity.most_recent_membership)}"
      end

      #  Get a short info string for the given membership; shows id, first day and last day. Used for debugging and to see if a membership can be renewed
      # @param [Membership | Nil ] membership The membership to use for the string
      # @return [String] The info string for the membership. Is 'nil' if the membership is nil
      def short_membership_str(membership)
        return 'nil' if membership.nil?

        "[#{membership.id}] #{membership.first_day} - #{membership.last_day}"
      end

      def reset_failed_requirements
        @failed_requirements = []
      end

      # Return a list of why the requirements methods failed.
      # This is a work in progress; this is just an initial idea.
      #
      # @return [Array<Hash>] List of hashes, where each Hash has a :string (value = a String that describes what failed)
      #    :method (value = Symbol of the method that failed), and :method_args (value = list of arguments passed to the method)
      def failed_requirements
        @failed_requirements
      end
    end
    # ==================================================================================================

    def failed_requirements
      self.class.failed_requirements
    end
  end
end
