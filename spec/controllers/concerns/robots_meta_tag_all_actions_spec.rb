require 'rails_helper'



RSpec.describe 'RobotsMetaTagAllActions' do

  class TestRobotsMetaTagAllController < ApplicationController
    include RobotsMetaTagAllActions

    actions = [:show, :index, :edit, :update, :delete, :destroy, :this_action, :that_action].freeze
    actions.each do |action|
      define_method(action) {}
    end
  end

  describe 'action_should_have_robots_none_tag?' do

    describe 'true for all  actions' do

      TestRobotsMetaTagAllController.new.action_methods.each do |action_name|
        it "#{action_name}" do
          subject = TestRobotsMetaTagAllController.new
          expect(subject.send(:action_should_have_robots_none_tag?, action_name.to_s)).to be_truthy
        end
      end
    end
  end

end
