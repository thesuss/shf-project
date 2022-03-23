require 'rails_helper'


RSpec.describe 'RobotsMetaTagShowActionOnly' do

  class TestRobotsMetaTagShowController < ApplicationController
    include RobotsMetaTagShowActionOnly

    actions = [:show, :index, :edit, :update, :delete, :destroy, :this_action, :that_action].freeze
    actions.each do |action|
      define_method(action) {}
    end
  end

  describe 'action_should_have_robots_none_tag?' do

    it 'false for show action' do
      subject = TestRobotsMetaTagShowController.new
      expect(subject.send(:action_should_have_robots_none_tag?, 'show')).to be_falsey
    end

    describe 'true for all other actions' do
      all_other_actions = TestRobotsMetaTagShowController.new.action_methods.reject { |action_name| action_name == 'show' }
      all_other_actions.each do |action_name|
        it "#{action_name}" do
          subject = TestRobotsMetaTagShowController.new
          expect(subject.send(:action_should_have_robots_none_tag?, action_name.to_s)).to be_truthy
        end
      end
    end
  end

end
