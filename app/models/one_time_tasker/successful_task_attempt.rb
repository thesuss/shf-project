module OneTimeTasker

#--------------------------
#
# @class SuccessfulTaskAttempt
#
# @desc Responsibility: A successful task attempt. :was_successful is always true
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-02
#
# @file successful_task_attempt
#
#--------------------------
  class SuccessfulTaskAttempt < TaskAttempt
    IS_SUCCESSFUL_VALUE = true

    after_initialize :set_as_successful

    validates_inclusion_of :was_successful, in: [IS_SUCCESSFUL_VALUE],
                           message:             I18n.t('activerecord.errors.models.successful_task_attempt.attributes.was_successful.invalid')

    default_scope { where(was_successful: IS_SUCCESSFUL_VALUE) }


    def set_as_successful
      self.was_successful = IS_SUCCESSFUL_VALUE
      self.attempted_on   = Time.zone.now
    end

  end

end
