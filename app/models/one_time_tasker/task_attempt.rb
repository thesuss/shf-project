
module OneTimeTasker

  #--------------------------
  #
  # @class TaskAttempt
  #
  # @desc Responsibility: A record of an attempt to run a Rake::Task
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2019-06-02
  #
  # @file task_attempt
  #
  #--------------------------
  class TaskAttempt < ApplicationRecord

    self.table_name = "one_time_tasker_task_attempts"

    validates_presence_of :task_name, :attempted_on

    # Note that Rails will still allow a _string_ for the value if you use these
    # two validations as given in the Rails 5.x guide:
    # https://guides.rubyonrails.org/active_record_validations.html
    #   validates :was_successful, inclusion: { in: [true, false] }
    #   validates :was_successful, exclusion: { in: [nil] }
    # So a custom validator is used
    validate :was_successful_is_boolean

    scope :successful, -> { where(was_successful: true) }
    scope :unsuccessful, -> { where(was_successful: false) }


    # Validation method for was_successful:
    # must be a boolean _and_ we must have a time for attempted_on
    def was_successful_is_boolean

      i18n_error_key = 'activerecord.errors.models.task_attempt.attributes.was_successful.invalid'
      type_is_valid       = self.was_successful.is_a?(TrueClass) || self.was_successful.is_a?(FalseClass)

      errors.add(:was_successful, I18n.t(i18n_error_key, value: self.was_successful)) unless type_is_valid
      has_been_attempted = !self.attempted_on.nil?
      has_been_attempted && type_is_valid
    end


    # methods for readability
    def successful?
      !!was_successful # the double '!'s ensure that you get a TrueClass or FalseClass returned. Ex: original value could be a 1 or 0 (especially since this depends on database representation + ActiveRecord stuff)
    end


    def failed?
      !was_successful
    end


    def has_been_attempted?
      !self.attempted_on.nil?
    end

  end

end
