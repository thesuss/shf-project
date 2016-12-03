require 'rails_helper'
require "#{File.join(__dir__, 'rake')}"


RSpec.describe 'shf:import_membership_apps' do
  include_context 'rake'


  CSV_DIR = File.join(Rails.root, 'spec', 'fixtures', 'test-import-files')

  describe 'all data is valid' do

    VALID_FILE = 'applications-from-prev-system.csv'

    it 'should process without any errors' do
      expect { subject.invoke(File.join(CSV_DIR, VALID_FILE)) }.not_to raise_error
    end

    it 'should write to a log file' do
      false
    end

    describe 'should create 4 users' do

      before(:all) do
      end

      # TODO run and get the output from the log file.

      it 'create users' do
        #orig_num_users = Users.all.count
        subject.invoke(File.join(CSV_DIR, VALID_FILE))

      #  expect(Users.all.count).to eq(orig_num_users + 4)
      end
      it "new users have default password 'whatever' " do
        #orig_num_users = Users.all.count
       # subject.invoke(File.join(CSV_DIR, VALID_FILE))

      #  expect(Users.first.password).to eq 'whatever'
      end

    end

    it 'should create x member applications' do
#      subject.invoke('valid-applications.csv')
      pending
    end

    it 'should create x companies' do
 #     subject.invoke('valid-applications.csv')
      pending
    end
  end

  describe 'problems' do

    let(:invalid_csv_file) { 'csv-invalid.csv' }

    it 'error if no filename given to the task' do
      expect { subject.invoke }.to raise_exception
    end

    it 'error if file does not exist' do
      expect { subject.invoke 'file-does-not-exist.tmp' }.to raise_exception(LoadError)
    end

  end


end