require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  describe 'action_should_have_robots_none_tag?' do

    describe 'false for show and index actions' do
      ['show', 'index'].each do |action_name|
        it "#{action_name}" do
          expect(subject.send(:action_should_have_robots_none_tag?, action_name)).to be_falsey
        end
      end
    end

    describe 'true for all other actions' do
      all_other_actions = described_class.new.action_methods.reject { |action_name| action_name == 'show' || action_name == 'index' }
      all_other_actions << 'blorf'
      all_other_actions.each do |action_name|
        it "#{action_name}" do
          expect(subject.send(:action_should_have_robots_none_tag?, action_name)).to be_truthy
        end
      end
    end
  end


  describe '#test_exception_notifications' do

    before(:each) { ExceptionNotifier.testing_mode! }
    after(:each) { ExceptionNotifier.testing_mode = false }


    it 'message for notification = this is just a test' do
      expect { subject.test_exception_notifications }.to raise_error(RuntimeError, 'This is a just a test of the exception notifications to ensure they are working.')
    end

  end


end
