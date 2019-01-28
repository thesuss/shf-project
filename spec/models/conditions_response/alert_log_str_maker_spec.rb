require 'rails_helper'


RSpec.describe AlertLogStrMaker do

    let(:alert) { HBrandingFeeDueAlert.instance }
    let(:success_method) { :success_str }
    let(:failure_method) { :failure_str }


    it 'sends the success_method to the alert with the log_args' do

      alert_log_str_maker = described_class.new(alert, success_method, failure_method)

      allow(alert).to receive(:success_str).with('hello', 'there')
                           .and_return('hello there')
      expect(alert_log_str_maker.success_info(['hello', 'there'])).to eq 'hello there'
    end


    it 'sends the failure_method to the alert with the log_args' do

      alert_log_str_maker = described_class.new(alert, success_method, failure_method)

      allow(alert).to receive(:failure_str).with('goodbye', 'there')
                          .and_return('goodbye there')
      expect(alert_log_str_maker.failure_info(['goodbye', 'there'])).to eq 'goodbye there'
    end

end
