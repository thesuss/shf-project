require 'rails_helper'
require 'support/validator_helper'
include ValidatorHelper

RSpec.describe DinkursIdValidator do
  let(:model) { ValidatorHelper.test_model_class }
  let(:record) { model.new }

  let(:error_msg) { I18n.t('activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_chars') }

  before(:each) do
    record.class_eval do
      validates :test_attr, dinkurs_id: true
    end
  end

  it 'adds error message when key contains invalid characters' do
    record.test_attr = 'abcDEä'
    expect { record.valid? }
      .to change(record.errors, :messages).from({})
      .to a_hash_including(test_attr: [error_msg])
    # reference: http://rspec.info/blog/2014/01/new-in-rspec-3-composable-matchers/
  end

  it 'does not add error message if no special characters' do
    record.test_attr = 'abcDEF'
    expect { record.valid? }.not_to change(record.errors.messages, :count).from(0)
  end
end
