require 'rails_helper'
include ApplicationHelper

# Since DataPostCheckboxHelper is a module, we test it using a class that includes it
RSpec.describe UserChecklistsHelper, type: :helper do

  describe 'checkbox_with_post' do

    it 'sanitizes the name and addes it and "checkbox" to the CSS classes' do
      expect(helper.checkbox_with_post('__BAD! name[]', 'value', 'checked', 'some_path')).to match(/class="checkbox.--BAD--name-"/)
    end

    it 'adds data:{ remote: true, method: :post, url: <post path>} to the checkbox' do
      expect(helper.checkbox_with_post('name', 'value', 'checked', 'some_path')).to match(/data-remote="true" data-method="post" data-url="some_path"/)
    end

  end

end
