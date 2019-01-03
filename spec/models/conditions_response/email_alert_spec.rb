require 'rails_helper'
require 'email_spec/rspec'
require 'timecop'


LOG_DIR      = 'tmp'
LOG_FILENAME = 'testlog.txt'


RSpec.describe EmailAlert, type: :model do

  let(:user) { create(:user) }

  let(:config) { { days: [2, 5, 10] } }

  let(:condition) { create(:condition, config: { days: [2, 5, 10] }) }
  let(:timing) { :on }

  let(:filepath) { File.join(Rails.root, LOG_DIR, LOG_FILENAME) }
  let(:log) { ActivityLogger.open(filepath, 'TEST', 'open', false) }


  before(:each) do
    File.delete(filepath) if File.file?(filepath)
  end

  after(:all) do
    tmpfile = File.join(Rails.root, LOG_DIR, LOG_FILENAME)
    File.delete(tmpfile) if File.exist?(tmpfile)
  end


  describe '.condition_response' do

    let(:dec_1) { Time.zone.local(2018, 12, 1) }

    let(:users) do
      [create(:user, first_name: 'u1'),
       create(:user, first_name: 'u2')]
    end


    it 'gets the config from the condition' do
      # stubbed methods:
      allow(described_class.instance).to receive(:entities_to_check)
                                    .and_return([])

      allow(described_class.instance).to receive(:send_alert_this_day?)
                                    .and_return(true)

      allow(described_class.instance).to receive(:send_email)
                                    .with(anything, log)

      # expected results:
      expect(described_class).to receive(:get_config)

      # actual test:
      Timecop.freeze(dec_1) do
        described_class.instance.condition_response(condition, log)
        log.close
      end
    end

    it 'gets the timing from the condition' do
      # stubbed methods:
      allow(described_class.instance).to receive(:entities_to_check)
                                    .and_return([])

      allow(described_class.instance).to receive(:send_alert_this_day?)
                                    .and_return(true)

      allow(described_class.instance).to receive(:send_email)
                                     .with(anything, log)

      # expected results:
      expect(described_class).to receive(:get_timing)

      # actual test:
      Timecop.freeze(dec_1) do
        described_class.instance.condition_response(condition, log)
        log.close
      end
    end


    it 'calls send_email for the entity and log if send_alert_this_day? is true' do

      # stubbed methods:
      allow(described_class.instance).to receive(:entities_to_check)
                                    .and_return(users)

      allow(described_class.instance).to receive(:send_alert_this_day?)
                                    .with(timing, config, anything)
                                    .and_return(true)

      # expected results:
      expect(described_class.instance).to receive(:send_alert_this_day?)
                                     .with(timing, config, anything)
                                     .exactly(users.size).times

      expect(described_class.instance).to receive(:send_email)
                                     .with(anything, log)
                                     .exactly(users.size).times

      # actual test:
      Timecop.freeze(dec_1) do
        described_class.instance.condition_response(condition, log)
        log.close
      end
    end

    it 'does nothing when send_alert_this_day? is false for a user' do

      # stubbed methods:
      allow(described_class.instance).to receive(:entities_to_check)
                                    .and_return(users)

      allow(described_class.instance).to receive(:send_alert_this_day?)
                                    .with(anything, config, user)
                                    .and_return(false)

      # expected results:
      expect(described_class.instance).to receive(:send_alert_this_day?)
                                     .with(anything, config, anything)
                                     .twice

      expect(described_class.instance).to receive(:send_email).never

      # actual test:
      Timecop.freeze(dec_1) do
        described_class.instance.condition_response(condition, log)
        log.close
      end # Timecop
    end # it 'does nothing when send_alert_this_day? is false for a user'

  end


  it '.entities_to_check raises NoMethodError (subclasses should implement)' do
    expect { described_class.instance.entities_to_check }.to raise_exception NoMethodError
  end


  it '.mailer_class raises NoMethodError (subclasses should implement)' do
    expect { described_class.instance.mailer_class }.to raise_exception NoMethodError
  end


  it '.mailer_args raises NoMethodError (subclasses should implement)' do
    expect { described_class.instance.mailer_args(create(:user)) }.to raise_exception NoMethodError
  end


  describe '.send_email' do

    before(:all) do

      # define a method for MemberMailer just for this test
      MemberMailer.class_eval do
        def fake_mailer_method(_user)
          nil
        end
      end

    end

    after(:all) do
      # remove the method we added
      MemberMailer.undef_method(:fake_mailer_method)
    end


    before(:each) do
      Rails.configuration.action_mailer.delivery_method = :mailgun
      ApplicationMailer.mailgun_client.enable_test_mode!
    end

    after(:each) { ApplicationMailer.mailgun_client.disable_test_mode! }

    let(:dec_1) { Time.zone.local(2018, 12, 1) }
    let(:entity) { create(:member_with_membership_app) }


    it 'sends alert email to user and logs a message' do
      expect(MemberMailer.fake_mailer_method(user)).to be_truthy

      # stubbed methods:
      allow(described_class.instance).to receive(:mailer_class)
                                    .and_return(MemberMailer)
      allow(described_class.instance).to receive(:mailer_args)
                                    .and_return([entity])
      allow(described_class.instance).to receive(:mailer_method).and_return(:test_email)

      allow(described_class.instance).to receive(:success_str).with(entity)
                                    .and_return('succeeded with entity')

      # expected results:
      expect(MemberMailer).to receive(:test_email).with(entity)
                                  .and_call_original
      expect(log).to receive(:record)
                         .and_call_original

      Timecop.freeze(dec_1)
      described_class.instance.send_email(entity, log)
      Timecop.return

      email = ActionMailer::Base.deliveries.last
      expect(email).to deliver_to(entity.email)

      expect(File.read(filepath)).to include("[info] EmailAlert email sent succeeded with entity")
    end


    it 'logs an error if any error is raised or mail has errors' do
      expect(MemberMailer.fake_mailer_method(user)).to be_truthy

      # stubbed methods:
      allow(described_class.instance).to receive(:mailer_class)
                                    .and_return(MemberMailer)
      allow(described_class.instance).to receive(:mailer_args)
                                    .and_return([entity])
      allow(described_class.instance).to receive(:mailer_method).and_return(:test_email)

      allow(described_class.instance).to receive(:failure_str).with(entity)
                                    .and_return('failed with entity')

      allow_any_instance_of(Mail::Message).to receive(:deliver)
                                                  .and_raise(Net::ProtocolError)

      # expected results:
      expect(MemberMailer).to receive(:test_email).with(entity)
                                  .and_call_original

      Timecop.freeze(dec_1)
      described_class.instance.send_email(entity, log)
      Timecop.return

      expect(ActionMailer::Base.deliveries.size).to eq 0
      expect(File.read(filepath)).to include("[error] EmailAlert email ATTEMPT FAILED failed with entity.")
    end

  end


  describe '.mail_message' do

    let(:entity) { create(:company) }

    it 'calls mailer_args to get the arguments' do

      # stubbed methods:
      allow(described_class.instance).to receive(:mailer_method).and_return(:test_email)
      allow(described_class.instance).to receive(:mailer_class).and_return(MemberMailer)

      expect(described_class.instance).to receive(:mailer_args).with(entity)

      described_class.instance.mail_message(entity)
    end

    it 'calls mailer_class to get the mailer class' do
      # stubbed methods:
      allow(described_class.instance).to receive(:mailer_method).and_return(:test_email)
      allow(described_class.instance).to receive(:mailer_class).and_return(MemberMailer)
      allow(described_class.instance).to receive(:mailer_args).and_return([entity])

      expect(described_class.instance).to receive(:mailer_class)
``
      described_class.instance.mail_message(entity)
    end

    it 'sends the mailer_method to the mailer_class with the arguments' do
      # stubbed methods:
      allow(described_class.instance).to receive(:mailer_method).and_return(:test_email)
      allow(described_class.instance).to receive(:mailer_class).and_return(MemberMailer)
      allow(described_class.instance).to receive(:mailer_args).and_return([entity])

      expect(MemberMailer).to receive(:test_email).with(entity)

      described_class.instance.mail_message(entity)
    end

  end


  describe '.send_on_day_number?' do

    let(:config) { { days: [1, 3, 5] } }

    it 'true if config[:days].include? day_number' do
      expect(described_class.instance.send_on_day_number?(3, config)).to be_truthy
    end

    it 'false if day_number is not in config[:days]' do
      expect(described_class.instance.send_on_day_number?(0, config)).to be_falsey
    end

    it 'false if config does not have :days as a key' do
      expect(described_class.instance.send_on_day_number?(3, { blorf: 'blorf' })).to be_falsey
    end

  end


  it '.log_msg_start is the class name' do
    expect(described_class.instance.log_msg_start).to eq described_class.name
  end


  describe '.log_mail_response' do

    let(:entity) { create(:user) }


    it 'calls log_msg_start' do
      mail_response_dbl = double('Mail::Message')
      allow(mail_response_dbl).to receive(:errors).and_return([])

      expect(EmailAlert.instance).to receive(:log_msg_start).and_call_original

      expect(EmailAlert.instance.log_str_maker).to receive(:success_info).and_call_original
      expect(EmailAlert.instance).to receive(:success_str).and_return('success!')
      expect(EmailAlert.instance).to receive(:log_success)
                                .with(log, 'EmailAlert', anything)

      described_class.instance.log_mail_response(log, mail_response_dbl, entity)
    end


    context 'no mail_response errors (successful)' do

      it 'sends log_success' do

        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([])
        expect(EmailAlert.instance.log_str_maker).to receive(:success_info).and_call_original
        expect(EmailAlert.instance).to receive(:success_str).and_return('success!')

        expect(EmailAlert.instance).to receive(:log_success).with(log, 'EmailAlert', anything)

        described_class.instance.log_mail_response(log, mail_response_dbl, entity)
      end
    end


    context 'with mail_response_errors (failure)' do

      it 'sends log_failure' do

        mail_response_dbl = double("Mail::Message")
        allow(mail_response_dbl).to receive(:errors).and_return([3])
        expect(EmailAlert.instance.log_str_maker).to receive(:failure_info).and_call_original
        expect(EmailAlert.instance).to receive(:failure_str).and_return('failed!')

        expect(EmailAlert.instance).to receive(:log_failure).with(log, 'EmailAlert', anything)

        described_class.instance.log_mail_response(log, mail_response_dbl, entity)
      end
    end
  end


  describe '.log_success' do

    it 'writes info to the log with the userid and email' do
      described_class.instance.log_success(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("[info] log-start-msg email sent user-info.")
    end
  end


  describe '.log_failure' do

    it 'writes an error message to the log' do
      described_class.instance.log_failure(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("[error] log-start-msg email ATTEMPT FAILED user-info")
    end

    it 'includes error info if any error: is given' do
      described_class.instance.log_failure(log, 'log-start-msg', 'user-info', Net::ProtocolError)
      expect(File.read(filepath)).to include("[error] log-start-msg email ATTEMPT FAILED user-info. #{Net::ProtocolError}")
    end

    it "says 'Also see for possible info' with the Mailer log" do
      described_class.instance.log_failure(log, 'log-start-msg', 'user-info')
      expect(File.read(filepath)).to include("Also see for possible info #{ApplicationMailer::LOG_FILE}")
    end
  end


  it '.success_str raises NoMethodError (should be defined by subclasses)' do
    expect{ described_class.instance.success_str([])}.to raise_exception NoMethodError
  end


  it '.failure_str raises NoMethodError (should be defined by subclasses)' do
    expect{ described_class.instance.failure_str([])}.to raise_exception NoMethodError
  end


  it '.send_alert_this_day?(timing, config, user) raises NoMethodError (should be defined by subclasses)' do
    config = {}
    timing = 'blorf' # doesn't matter what this is
    expect { described_class.instance.send_alert_this_day?(timing, config, user) }.to raise_exception NoMethodError
  end

  it '.mailer_method raises NoMethodError (should be defined by subclasses)' do
    expect { described_class.instance.mailer_method }.to raise_exception NoMethodError
  end

end
