require 'rails_helper'

require 'timecop'

LOG_DIR      = 'tmp'
LOG_FILENAME = 'testlog.txt'


RSpec.describe UserEmailAlert, type: :model do

  let(:user) { create(:user) }

  let(:config) { { days: [2, 5, 10] } }

  # create a double for a condition that responds with a config
  let(:condition) { create(:condition, config: { days: [2, 5, 10] }) }


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

    before(:all) do

      # define a method for MemberMailer just for this test
      MemberMailer.class_eval do
        def fake_mailer_method(_user)
          true
        end
      end

    end


    after(:all) do
      # remove the method we added
      MemberMailer.undef_method(:fake_mailer_method)
    end


    let(:dec_1) { Time.zone.local(2018, 12, 1) }


    it 'for each User: sends alert and logs if send_alert_this_day? is true' do

      expect(MemberMailer.fake_mailer_method(user)).to be_truthy


      # stubbed methods:
      allow(described_class).to receive(:mailer_method).and_return(:fake_mailer_method)

      allow(described_class).to receive(:send_alert_this_day?)
                                    .with(config, user, dec_1)
                                    .and_return(true)

      allow(described_class).to receive(:log_msg_start).and_return('UserEmailAlert')


      # expected results:
      expect(MemberMailer).to receive(:fake_mailer_method).with(user)
                                  .exactly(1).times

      expect(described_class).to receive(:send_alert_this_day?)
                                     .with(config, user, dec_1)

      expect(log).to receive(:record)
                         .exactly(1 + 2).times
                         .and_call_original


      Timecop.freeze(dec_1) do
        described_class.condition_response(nil, config, log)
        log.close
      end # Timecop

      expect(File.read(filepath)).to include "[info] UserEmailAlert alert sent to #{user.email}"

    end

    it 'does nothing when send_alert_this_day? is false for a user' do

      # stubbed methods:
      allow(described_class).to receive(:send_alert_this_day?)
                                    .with(config, user, dec_1)
                                    .and_return(false)

      allow(described_class).to receive(:mailer_method).and_return(:fake_mailer_method)


      # expected results:
      expect(MemberMailer).not_to receive(:fake_mailer_method).with(user)

      expect(described_class).to receive(:send_alert_this_day?)
                                     .with(config, user, dec_1)

      expect(log).to receive(:record)
                         .exactly(2).times
                         .and_call_original


      # actual test:
      Timecop.freeze(dec_1) do
        described_class.condition_response(nil, config, log)
        log.close
      end # Timecop

      expect(File.read(filepath)).not_to include "[info] UserEmailAlert alert sent to #{user.email}"

    end

  end


  describe '.log_message' do

    it 'creates the string to write out to the log' do
      expect(described_class.log_message('UserEmailAlert', 'email@example.com')).to eq "UserEmailAlert alert sent to email@example.com"
    end

    it 'default message start is an empty string' do
      expect(described_class.log_message(nil, 'email@example.com')).to eq " alert sent to email@example.com"
    end

    it 'default email is an empty string' do
      expect(described_class.log_message('UserEmailAlert', nil)).to eq "UserEmailAlert alert sent to "
    end
  end


  describe '.days_since = number of whole days since a Time, rounded UP' do

    let(:nov_1) { Time.zone.local(2018, 11, 1) }
    let(:oct_1) { Time.zone.local(2018, 10, 1) }
    let(:also_oct_1) { Time.zone.local(2018, 10, 1) }

    it 'returns positive if date_time1 is before date_time2' do
      expect(described_class.days_since(oct_1, nov_1)).to be(31)
    end

    it 'returns negative if date_time1 is after date_time2' do
      expect(described_class.days_since(nov_1, oct_1)).to be(-31)
    end

    it 'returns 0 if the DateTimes are the same' do
      expect(described_class.days_since(oct_1, also_oct_1)).to be 0
    end

    it 'returns the days since Time.zone.local if only the first arg is given' do
      Timecop.freeze(Time.zone.local(2018, 12, 1)) do
        expect(described_class.days_since(nov_1)).to be 30
      end # Timecop
    end

  end


  describe '.send_on_day_number?' do

    let(:config) { { days: [1, 3, 5] } }

    it 'true if config[:days].include? day_number' do
      expect(described_class.send_on_day_number?(3, config)).to be_truthy
    end

    it 'false if day_number is not in config[:days]' do
      expect(described_class.send_on_day_number?(0, config)).to be_falsey
    end

    it 'false if config does not have :days as a key' do
      expect(described_class.send_on_day_number?(3, { blorf: 'blorf' })).to be_falsey
    end

  end


  it '.log_msg_start is the class name' do
    expect( described_class.log_msg_start ).to eq described_class.name
  end


  it '.send_alert_this_day?(_config, _user) raises NoMethodError (should be defined by subclasses)' do
    config = {}
    expect { described_class.send_alert_this_day?(config, user) }.to raise_exception NoMethodError
  end

  it '.mailer_method raises NoMethodError (should be defined by subclasses)' do
    expect { described_class.mailer_method }.to raise_exception NoMethodError
  end

end
