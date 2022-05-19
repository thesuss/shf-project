# frozen_string_literal: true

#--------------------------
#
# UserChecklistManager
#
# @responsibility Handle all behavior and queries for a UserChecklist associated with a User. This is
#   mostly about the _membership guidelines checklist_ (and perhaps should be renamed to reflect that).
#
#   - determines if a user has agreed to the _membership guidelines checklist_
#     based on the date all were completed and the membership status.
#   - can create a new _membership guidelines checklist_ for a user if needed
#   - return the most recently completed _membership guidelines checklist_
#
# Business rule: Once a membership expires and they are in the grace period
#   they must agree to the Membership guidelines again.
#
# 2020-12-07  Business Rule: Everyone must always agree to the membership guidelines,
# no matter when their term starts/ends, etc.
# The only limiting factor is when the Membership Guidelines requirement started.
#
# @todo move this into /services folder since this is all behavior and no persistence
# @todo This definitely shows (smells!) that the User model should be refactored along the membership_status;
#   there is lots of conditional code based on the membership_status
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/23/20
#
#--------------------------

class UserChecklistManager

  # The date when we started requiring users to agree to Membership Guidelines
  # (This is the date when Memberships were fully implemented for new users and current members.)
  MEMBERSHIP_GUIDELINES_AGREE_ANYTIME_CUTOFF_DATE = Date.new(2021, 11, 1)

  # ---------------------------------------------------------------------------------------------


  # A user can do (complete/check off) the membership guidelines if they have a SHF Application.
  #
  # @return [true,false]
  def self.can_user_do_membership_guidelines?(user)
    !!user&.shf_application
  end


  # Has the user completed (agreed to) to the membership guidelines within the right time period?
  #
  # If the user is a **current member**
  #   If we are checking to see if the guidelines are complete for a renewal,
  #    then we check to see if they have been completed on or after the current membership
  #    else they must have completed the guidelines for the current membership
  #
  # If the user is **not yet a member**, they must have agreed to the membership guidelines.
  # _(No specific time frame is required.)_
  #
  # If a user is a **member in the grace period** or a **former member**,
  # they must agree to the membership guidelines after the last day of the most recent membership,
  # _even if they agreed to them during that membership._  This is so that they agree to them again
  # and to (slightly) deter them from waiting to renew after the last day of the most recent membership.
  #
  # @param user [User] The user to check
  # @return [true,false]
  def self.completed_membership_guidelines_checklist?(user)
    case user.membership_status.to_sym
      when User::STATE_NOT_A_MEMBER
        !!find_or_create_membership_guidelines_list(user)&.all_completed?
      when User::STATE_CURRENT_MEMBER
        current_member_completed_membership_guidelines_checklist?(user)
      when User::STATE_IN_GRACE_PERIOD, User::STATE_FORMER_MEMBER
        !!find_after_latest_membership_end(user)&.all_completed?
      else
        false
    end
  end

  # @return [true,false]
  def self.completed_membership_guidelines_checklist_for_renewal?(user)
    case user.membership_status.to_sym
      when User::STATE_CURRENT_MEMBER
        current_member_completed_membership_guidelines_checklist_for_renewal?(user)
      when User::STATE_IN_GRACE_PERIOD
        in_grace_period_completed_membership_guidelines_checklist_for_renewal?(user)
      else
        false
    end
  end

  # Has the current member completed the membership guidelines in the time period required?
  # Business rules:
  # Before the full Membership model (class) was implemented, some members had already read an agreed to the membership guidelines.
  # Those members don't have to agree to the guidelines until they renew.
  #
  # If a current member has paid for individual memberships in advance
  # AND they agreed to the guidelines on or before the date they paid,
  #   they don't have to agree again until
  #   (1) they need to pay again, OR
  #   (2) a new, (uncompleted/unagreed to) membership guidelines checklist is created for them.
  #
  # If a current member has not paid in advance AND did not agree before the full Membership model was implemented,
  # they must have agreed within the window for renewing their current membership, or applying if they are new members.
  #
  # @return [true,false]
  def self.current_member_completed_membership_guidelines_checklist?(current_member)
    return false unless current_member.current_member?

    if UserChecklist.not_completed_by_user(current_member).empty? && !UserChecklist.completed_by_user(current_member).empty?
      most_recent_agreed_to_guideline_date = UserChecklist.most_recent_completed_top_level_guideline(current_member).date_completed.to_date
      if most_recent_agreed_to_guideline_date < membership_guidelines_required_date
        true
      else
        if Memberships::MembershipsManager.user_paid_in_advance?(current_member)
          # They don't have to agree again until they need to pay again (or if a new, uncompleted list is created for them for some reason -- like the SHF board has updated the guidelines, etc.)
          most_recent_agreed_to_guideline_date <= current_member.most_recent_payment.created_at # FIXME - this won't work for scenarios unless we manually set the created_at date
        else
          # they must have agreed to the guidelines within the window for agreeing to the guidelines for the current membership
          # all_completed = UserChecklist.completed_top_level_guidelines(current_member)
          # all_completed_dates = all_completed.map(&:date_completed)

          Memberships::MembershipsManager.valid_membership_guidelines_agreement_date?(current_member.current_membership,
                                                                         most_recent_agreed_to_guideline_date)
        end
      end

    else
      false
    end
  end

  # Did the current member complete the membership guidelines checklist for renewal?
  # Did they complete it after the current membership started?
  #
  # @return [true,false]
  def self.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)
    return false unless current_member.current_member?
    return false if current_member.current_membership.nil?

    most_recent_agreed_to_guideline_date = UserChecklist.most_recent_completed_top_level_guideline(current_member)&.date_completed
    return false unless most_recent_agreed_to_guideline_date

    if current_member.current_membership.first_day < membership_guidelines_required_date && most_recent_agreed_to_guideline_date < membership_guidelines_required_date
      true
    else
      checklist_complete_after?(current_member, current_member.current_membership.first_day + 1.day)
    end
  end

  # Did the member in the grace period complete the membership guidelines checklist for renewal
  # after the most recent membership ended?
  #
  # @return [true,false]
  def self.in_grace_period_completed_membership_guidelines_checklist_for_renewal?(grace_pd_member)
    return false unless grace_pd_member.in_grace_period?

    checklist_complete_after?(grace_pd_member, grace_pd_member.most_recent_membership.last_day + 1.day)
  end


  # Are there any checklists for the user completed after the given date? (default date = Date.current )
  # @return [true, false]
  def self.checklist_complete_after?(user, date = Date.current)
    checklists_after_day = UserChecklist.most_recently_created_top_level_guidelines(user, date)
    checklists_after_day.empty? ? false : checklists_after_day.first.completed?
  end

  # Get the method to use to find or create the membership guidelines.
  # The method depends on the membership status _and_ if it is for a renewal or not.
  #
  # If it is a renewal
  #   then find or create the list after the _first day_ of the latest membership
  #
  # else
  #  if it is a new (not a member) or current member, find or create the membership guidelines
  #
  # If the member is in the grace period or a former member,
  #   then find or create the membership guidelines after the _last day_ of the most recent membership
  #
  # @todo rename this class to better reflect that it is mainly abou the Membership Guidelines?
  #
  # @param membership_status [String]
  # @param is_renewal [true, false]
  # @return [Symbol]
  def self.find_or_create_guidelines_method(membership_status, is_renewal: false)
    status = membership_status.to_sym # the attribute is a String, but AASM returns each status as a symbol
    if is_renewal &&
      (status == User::STATE_CURRENT_MEMBER || status == User::STATE_IN_GRACE_PERIOD)
      if status == User::STATE_CURRENT_MEMBER
        :find_or_create_on_or_after_current_membership_start
      else
        :find_or_create_after_latest_membership_last_day
      end
    else
      case status
        when User::STATE_CURRENT_MEMBER, User::STATE_NOT_A_MEMBER
          :find_or_create_membership_guidelines_list
        when User::STATE_IN_GRACE_PERIOD, User::STATE_FORMER_MEMBER
          :find_or_create_after_latest_membership_last_day
        else
          :find_or_create_membership_guidelines_list
      end
    end
  end


  # Find the uncompleted Membership Guidelines checklist that was created _on or after_ the first day
  # of the user's most recent membership
  # Create the membership guidelines checklist if there isn't one.
  # Used for renewals (ex: has the user agreed to the guidelines on or after the current membership start?)
  #
  # @param user [User]
  # @return [UserChecklist]
  def self.find_or_create_on_or_after_latest_membership_start(user)
    latest_membership_start = Memberships::MembershipsManager.most_recent_membership(user)&.first_day
    find_or_create_on_or_after(user, latest_membership_start)
  end


  # Find the uncompleted Membership Guidelines checklist that was created _on or after_ the first day
  # of the user's _current_ membership.
  # Create the membership guidelines checklist if there isn't one.
  # If there is not a current membership, create the membership guidelines checklist.
  #
  # @param user [User]
  # @return [UserChecklist]
  def self.find_or_create_on_or_after_current_membership_start(user)
    # If the current membership started before renewals were fully implemented,
    #   then they might have agreed to the guidelines before the current membership started
    #   else they must agree on or after the currrent membership first day
    current_membership_start = Memberships::MembershipsManager.current_membership(user)&.first_day

    find_or_create_on_or_after(user, current_membership_start)
  end

  # Find the uncompleted Membership Guidelines checklist that was created _ after_ the last day
  # of the user's most recent membership.
  # Create the membership guidelines checklist if there isn't one.
  #
  # @param user [User]
  # @return [nil, UserChecklist]
  def self.find_or_create_after_latest_membership_last_day(user)
    latest_membership_end = Memberships::MembershipsManager.most_recent_membership(user)&.last_day
    after_date = latest_membership_end.nil? ? nil : (latest_membership_end + 1.day)
    find_or_create_on_or_after(user, after_date&.to_date) # a nil date is meaningful
  end


  # Find the Membership Guidelines checklist that was created _on or after_ the first day
  # of the user's most recent membership. It may or may not be completed.
  # Return nil if there isn't one.
  #
  # @fixme is this used?
  #
  # @param user [User]
  # @return [nil, UserChecklist]
  # def self.find_on_or_after_latest_membership_start(user)
  #   latest_membership_start = Memberships::MembershipsManager.most_recent_membership(user)&.first_day
  #   find_or_create_on_or_after(user, latest_membership_start)
  # end


  # Find the Membership Guidelines checklist that was created _after_ the last day
  # of the user's most recent membership. (This returns the top level of the list and ignores whether or not items are completed.)
  # Return nil if there isn't one.
  #
  # @param user [User]
  # @return [nil, UserChecklist]
  def self.find_after_latest_membership_end(user)
    latest_membership_end = Memberships::MembershipsManager.most_recent_membership(user)&.last_day
    return nil unless latest_membership_end

    UserChecklist.most_recently_created_top_level_guidelines(user, latest_membership_end + 1.day).last
  end


  # Create a new membership guideline if we don't find one for the user that is _not completed_
  # and was created on or after the given date OR if we aren't given a date at all.
  # If we do find one, just return it.
  #
  # @param user [User]
  # @param on_or_after_date [nil, Date]
  # @return [UserChecklist]
  def self.find_or_create_on_or_after(user, on_or_after_date = nil)
    return create_for_user_if_needed(user) unless on_or_after_date

    found_guideline = UserChecklist.most_recently_created_top_level_guidelines(user, on_or_after_date)
                                   .uncompleted.last
    create_for_user_if_needed(user, guideline: found_guideline)
  end


  # Create a membership guidelines checklist for the given user if there isn't already one.
  #
  # @param user [User]
  # @return [UserChecklist]
  def self.find_or_create_membership_guidelines_list(user)
    create_for_user_if_needed(user, guideline: most_recent_membership_guidelines_list_for(user))
  end


  # If the given guideline is nil, create one for the user and return it,
  # else just return the guideline.
  #
  # @param user [User]
  # @param guideline [nil, UserChecklist]
  # @return [UserChecklist]
  def self.create_for_user_if_needed(user, guideline: nil)
    guideline.nil? ? create_for_user(user) : guideline
  end


  # Create a membership guideline checklist for the given user
  #
  # @param user [User]
  # @return [UserChecklist]
  def self.create_for_user(user)
    AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(user)
  end


  # Return the MOST RECENTLY created _top level_ membership guidelines checklist for the user (the root).
  # or nil if there aren't any.
  #
  # @return [nil, UserChecklist]
  def self.most_recent_membership_guidelines_list_for(user)
    UserChecklist.membership_guidelines_for_user(user)&.last
  end


  # Gets the first incomplete guideline (checklist) for the user for ANY checklist
  # - If the user does not have to complete the membership guidelines, return nil.
  # - If there are no guidelines, return nil.
  # - If there are no incomplete guidelines, return nil.
  # - Else return the first uncompleted checklist (since they are given to us here as sorted)
  # @return [nil, UserChecklist]
  def self.first_incomplete_membership_guideline_section_for(user)
    not_completed_guidelines_for(user)&.first
  end


  # @return [Array<UserChecklist>]
  def self.completed_guidelines_for(user)
    guidelines_for(user, :completed)
  end


  # @return [Array<UserChecklist>]
  def self.not_completed_guidelines_for(user)
    guidelines_for(user, :uncompleted)
  end


  # Get the guidelines for a user. Use the given completed_method to get just those that are completed
  # (default) or not.
  #
  # Return an empty list if there are none.
  #
  # The selection_block is being used explicitly so it's very clear.  (Could have also used yield.)
  #
  # @param user [User]
  # @param completed_method [Symbol] the method to use to get completed (or not) checklists. Default is :completed
  # @return [Array<UserChecklist>]
  def self.guidelines_for(user, completed_method = :completed)
    guideline_list = most_recent_membership_guidelines_list_for(user) ? most_recent_membership_guidelines_list_for(user) : {}
    return [] unless guideline_list.present?

    guideline_list.descendants&.send(completed_method).to_a&.sort_by { |kid| "#{kid.ancestry}-#{kid.list_position}" }
  end


  # Is a user's top-level checklist completed on or after the most recent membership?
  #
  # Return false if there is no membership for the user
  # @return [true,false]
  def self.checklist_done_on_or_after_latest_membership_start?(user)
    latest_membership_start = Memberships::MembershipsManager.most_recent_membership(user)&.first_day
    return false unless latest_membership_start

    most_recent_completed = UserChecklist.most_recent_completed_top_level_guideline(user)
    (!!most_recent_completed && most_recent_completed.date_completed.to_date >= latest_membership_start.to_date)
  end

  def self.membership_guidelines_required_date
    MEMBERSHIP_GUIDELINES_AGREE_ANYTIME_CUTOFF_DATE
  end
end
