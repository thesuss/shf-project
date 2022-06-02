# frozen_string_literal: true

#--------------------------
#
# @class Memberships::NewRenewMembershipActions
#
# @desc Responsibility: Do all the things that are common to creating or renewing a membership
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2022-05-21
#
# TODO: what if they are a current_member and the last day > the date?
#   end the current membership on (date - 1 day) and start the new one on the date?
#
#--------------------------------------------------------------------------------------------------
module Memberships
  class NewRenewMembershipActions < MembershipActions

    def self.other_keyword_args_valid?(other_keyword_args)
      !!other_keyword_args.fetch(:first_day, false)
    end

    # Create a new membership with the first day as the given first_day
    # Set the membership number for the entity
    # If we should send email:
    #   send the mail method to the mailer class, passing in the entity and the other arguments
    #
    # @fixme renamed to actions_successful?
    # @return [True, False]
    def self.accomplish_actions(entity, send_email: SEND_EMAIL_DEFAULT, **other_keyword_args)
      create_new_membership(entity, other_keyword_args[:first_day])
      set_is_a_member(entity) # @todo remove 'member' attribute and just check the membership status. This will be a big change
      if send_email
        mailer_class.send(mailer_method, entity).deliver
      end
      true
    end

    def self.create_new_membership(entity, first_day)
      # create a new Membership for the entity
      last_day = Membership.last_day_from_first(first_day) # @fixme Create the correct type of Membership. Use Membership factory
      entity.memberships << Membership.create!(owner: entity, first_day: first_day, last_day: last_day)

    end

    def self.set_is_a_member(entity)
      entity.update!(member: true)
    end
  end
end
