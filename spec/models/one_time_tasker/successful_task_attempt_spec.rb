require 'rails_helper'

RSpec.describe OneTimeTasker::SuccessfulTaskAttempt, type: :model do

  describe 'DB Table' do
    it 'uses the same table as the superclass (TaskAttempt)' do
      expect(described_class.table_name).to eq(described_class.superclass.table_name)
    end
  end


  it 'default_scope is where(was_successful: true)' do

    OneTimeTasker::TaskAttempt.delete_all

    create(:one_time_tasker_task_attempt, :successful_task, task_name: 'success1')
    create(:one_time_tasker_task_attempt, :successful_task, task_name: 'success2')
    create(:one_time_tasker_task_attempt, :successful_task, task_name: 'success3')
    create(:one_time_tasker_task_attempt, :unsuccessful_task, task_name: 'failure1')
    create(:one_time_tasker_task_attempt, :unsuccessful_task, task_name: 'failure2')

    expect(described_class.count).to eq 3
    expect(described_class.superclass.count).to eq 5

  end


  describe 'is set to successful after initialization' do

    it 'was_successful is true' do
      expect(described_class.new.was_successful).to be_truthy
    end

    it 'attempted_on is Time.zone.now' do
      faux_now = Time.zone.now
      Timecop.freeze(faux_now) do
        expect(described_class.new.attempted_on).to eq faux_now
      end
    end
  end


  describe 'was_successful can only be true' do

    before(:each) { subject.task_name = 'successful task'}


    it 'update(was_successful: false) will fail' do
      expect(subject.update(was_successful: false)).to be_falsey
    end

    it 'save! given was_successful = false shows the error message' do

      subject.was_successful = false

      escaped_error_message = I18n.t('activerecord.errors.models.successful_task_attempt.attributes.was_successful.invalid', value: false)
      # escape the parentheses in the error message so we can use RegExp
      escaped_error_message.gsub!('(', '\(')
      escaped_error_message.gsub!(')', '\)')
      expect{ subject.save! }.to raise_error(ActiveRecord::RecordInvalid,
                                             /#{escaped_error_message}/)
    end
  end

end
