require 'rails_helper'
require "#{File.join(__dir__, 'rake')}"


RSpec.describe 'shf:import_membership_apps' do
  include_context 'rake'


  CSV_DIR = File.join(Rails.root, 'spec', 'fixtures', 'test-import-files')

  describe 'all data is valid' do


    it 'should process without any errors' do
      expect { subject.invoke(File.join(CSV_DIR, 'valid-applications.csv')) }.not_to raise_error
    end

    describe 'should create 4 users' do

      before(:all) do
      end

      it 'create users' do
        #orig_num_users = Users.all.count
        subject.invoke(File.join(CSV_DIR, 'valid-applications.csv'))

      #  expect(Users.all.count).to eq(orig_num_users + 4)
      end
      it "new users have default password 'whatever' " do
        #orig_num_users = Users.all.count
        subject.invoke(File.join(CSV_DIR, 'valid-applications.csv'))

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
      expect { subject.invoke 'file-does-not-exist.tmp' }.to raise_exception
    end

  end


end