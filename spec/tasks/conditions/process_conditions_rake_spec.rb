require 'rails_helper'
require 'shared_context/rake'
require 'shared_context/activity_logger'

RSpec.describe 'conditions/process_conditions shf:process_conditions', type: :task do

  include_context 'rake'

  let(:filepath) { LogfileNamer.name_for(Condition) }

  before(:each) do
    File.delete(filepath) if File.file?(filepath)
  end

  let(:test_conditions) do
    [{ class_name: 'MembershipLapsedAlert',
       timing:     :after,
       config:     { days: [2, 9, 14, 30, 60] } },
    ]
  end


  describe 'failures' do

    before(:each) do

      # load the condition(s)
      if Condition.create(test_conditions)
        puts "  #{test_conditions.size} Conditions were loaded into the db: #{test_conditions.map { |h_cond| h_cond[:class_name] }.join(', ')}"
      end
    end


    describe 'Slack Notification failure' do

      it 'logs the error but keeps going' do

        # Slack notification error will be raised:
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_raise(Slack::Notifier::APIError)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        # precondition:
        # log should not have the Exception info
        if File.exist?(filepath)
          expect(File.read(filepath))
              .not_to include 'Slack::Notifier::APIError Exception:'
          expect(File.read(filepath))
              .not_to include 'Slack Notifications turned off! Condition processing continuing without it.'
          expect(File.read(filepath))
              .not_to include 'Retrying the previous condition...'
        end

        # the error will not percolate up and be rasied; processing continues
        expect { subject.invoke }.not_to raise_error

        # post-condition:
        # log should have the Exception info
        expect(File.read(filepath))
            .to include 'Slack::Notifier::APIError Exception:'
        expect(File.read(filepath))
            .to include 'Slack Notifications turned off! Condition processing continuing without it.'
        expect(File.read(filepath))
            .to include 'Retrying the previous condition...'
      end

    end

    describe 'any other failure will stop processing' do

      it 'logs the error and raises the error' do

        # error that will be raised:
        allow_any_instance_of(MembershipLapsedAlert).to receive(:condition_response)
                                                            .and_raise(EOFError)

        # stub out the Slack notification methods
        allow(SHFNotifySlack).to receive(:notification)
                                     .and_return(true)

        # should never create a SlackNotifier during this test
        expect(Slack::Notifier).not_to receive(:new)

        expected_exception_log_entry = 'Exception: EOFError:  #<EOFError: EOFError>'

        # precondition:
        # log should not have the Exception
        if File.exist?(filepath)
          expect(File.read(filepath))
              .not_to include expected_exception_log_entry
        end

        expect { subject.invoke }.to raise_error EOFError

        # post-condition:
        # log should have the Exception
        expect(File.read(filepath))
            .to include expected_exception_log_entry
      end

    end
  end

end
