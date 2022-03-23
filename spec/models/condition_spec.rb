require 'rails_helper'

RSpec.describe Condition, type: :model do

  describe 'Factory' do
    it 'has a valid factory' do
      expect(build(:condition)).to be_valid
    end
  end

  describe 'DB Table' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :class_name }
    it { is_expected.to have_db_column :timing }
    it { is_expected.to have_db_column :config }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:class_name) }

    context 'timing' do
      it { is_expected.to allow_value(:test).for(:timing) }
      it { is_expected.to_not allow_value('test').for(:timing)}
    end

    context 'config' do
      it { is_expected.to allow_value({}).for(:config) }
      it { is_expected.to_not allow_value(nil).for(:config) }
      it { is_expected.to_not allow_value([]).for(:config) }
      it { is_expected.to_not allow_value('').for(:config) }


      it 'config is initialized to an empty Hash' do
        expect(described_class.new.config).to eq({})
      end

    end
  end

  describe 'required attributes' do
    let(:example_condition) do
      create(:condition, class_name: 'MembershipExpireAlert',
                         timing: :before,
                         config: { days: [10, 5, 2] })
    end

    it 'class_name is required' do
      expect(example_condition).to be_valid
      expect{example_condition.update_column(:class_name, nil)}.to raise_error ActiveRecord::NotNullViolation
    end


    it 'config is required - cannot be nil but can be an empty Hash (via validating that it is a Hash)' do
      expect(example_condition).to be_valid
      example_condition.update(config: nil)
      expect(example_condition).not_to be_valid

      example_condition.update(config: {})
      expect(example_condition).to be_valid
    end


    it 'timing is optional' do
      expect(example_condition).to be_valid
      example_condition.update(timing: nil)
      expect(example_condition).to be_valid
    end

  end
end
