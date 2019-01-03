# Revoke membership status if requirements are met

class MembershipStatusCheck < ConditionResponder

  def self.condition_response(condition, log)

    confirm_correct_timing(get_timing(condition), TIMING_EVERY_DAY, log)

    status_updater = MembershipStatusUpdater.instance

    User.members.each do |user|

      status_updater.revoke_user_membership(user)

      unless user.reload.member
        log.record('info', "User #{user.id} (#{user.email}) membership revoked.")
      end

    end

  end

end
