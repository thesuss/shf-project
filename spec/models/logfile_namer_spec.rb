require 'rails_helper'


RSpec.describe LogfileNamer do

  describe 'Rails environment prefix' do

    it 'leaves off the Rails.env prefix in the production environment' do

      RSpec::Mocks.with_temporary_scope do

        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        expect(described_class.name_for(BasicObject)).to match(/BasicObject/)
        expect(described_class.name_for(BasicObject)).not_to match(/production_BasicObject/)
      end

    end

    ['development', 'test'].each do | rails_env |

      it "starts the filename with '#{rails_env}' if Rails.env.#{rails_env}?" do

        RSpec::Mocks.with_temporary_scope do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(rails_env))

          expect(described_class.name_for(BasicObject)).to match(/#{rails_env}_BasicObject/)
        end

      end
    end

  end

  it 'is in the Rails log directory (the first log dir encountered if there is more than one)' do
    log_path = File.dirname(Rails.configuration.paths['log'].expanded.first)
    expect(described_class.name_for(BasicObject)).to match(/^#{log_path}/)
  end

  it 'has .log as the extension' do
    expect(described_class.name_for(BasicObject)).to match(/.log$/)
  end

  it 'uses the class as the main log name' do
    expect(described_class.name_for(BasicObject)).to match(/BasicObject.log/)
  end

end
