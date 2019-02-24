require 'rails_helper'

RSpec.describe AdminOnly::FileDeliveryMethod, type: :model do

  let(:upload_now)     { create(:file_delivery_upload_now) }
  let(:upload_later)   { create(:file_delivery_upload_later) }
  let(:email)          { create(:file_delivery_email) }
  let(:mail)           { create(:file_delivery_mail) }
  let(:files_uploaded) { create(:file_delivery_files_uploaded) }

  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:file_delivery_method)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :description_sv }
    it { is_expected.to have_db_column :description_en }
    it { is_expected.to have_db_column :default_option }
  end

  describe 'Validations' do
    subject { create(:file_delivery_method) }
    
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_uniqueness_of :name }
    it { is_expected.to validate_presence_of :description_sv }
    it { is_expected.to validate_presence_of :description_en }
    it { is_expected.to validate_uniqueness_of :default_option }
    it 'should validate that :name is one of defined values' do
      subject { FactoryBot.build(:file_delivery_method)
      is_expected.to validate_inclusion_of(:name)
          .in_array([ AdminOnly::FileDeliveryMethod::METHOD_NAMES.values ]) }
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:shf_applications).dependent(:nullify) }
  end

  describe 'Scopes' do
    context '.default' do

      it 'returns default delivery option' do
        upload_now
        expect(AdminOnly::FileDeliveryMethod.default[0].name).to eq upload_now.name
      end
    end
  end

  describe 'Class methods' do
    context '.get_method' do

      let!(:klass) { AdminOnly::FileDeliveryMethod }

      it 'returns delivery method for all valid delivery name keys' do

        upload_now
        upload_later
        email
        mail
        files_uploaded

        expect(klass.get_method(:upload_now)).to eq upload_now
        expect(klass.get_method(:upload_later)).to eq upload_later
        expect(klass.get_method(:email)).to eq email
        expect(klass.get_method(:mail)).to eq mail
        expect(klass.get_method(:files_uploaded)).to eq files_uploaded
      end

      it 'raises exception if argument is not a symbol' do
        expect{ klass.get_method('not_a_symbol') }.to raise_error(ArgumentError,
                'Argument must be a symbol and a known delivery name key')
      end

      it 'raises exception if argument is not a valid delivery name key' do
        expect{ klass.get_method(:not_valid) }.to raise_error(ArgumentError,
                'Argument must be a symbol and a known delivery name key')
      end
    end
  end
end
