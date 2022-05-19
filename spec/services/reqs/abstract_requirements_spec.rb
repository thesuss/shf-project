require 'rails_helper'

module Reqs
  RSpec.describe AbstractRequirements do

    let(:subject) { AbstractRequirements }

    describe '.satisfied?' do

      it 'checks that the expected arguments are there and the requirements are met' do
        expect(subject).to receive(:has_expected_arguments?).and_return(true)
        expect(subject).to receive(:requirements_met?)
        subject.satisfied?('blorf')
      end

      it '.has_expected_arguments? is true and requirements_met? is true' do
        allow(subject).to receive(:has_expected_arguments?).and_return(true)
        allow(subject).to receive(:requirements_met?).and_return(true)
        expect(subject.satisfied?('blorf')).to be_truthy
      end

      it '.has_expected_arguments? is true and requirements_met? is false' do
        allow(subject).to receive(:has_expected_arguments?).and_return(true)
        allow(subject).to receive(:requirements_met?).and_return(false)
        expect(subject.satisfied?('blorf')).to be_falsey
      end

      it '.has_expected_arguments? is false and requirements_met? is true' do
        allow(subject).to receive(:has_expected_arguments?).and_return(false)
        allow(subject).to receive(:requirements_met?).and_return(true)
        expect(subject.satisfied?('blorf')).to be_falsey
      end

      it '.has_expected_arguments? is false and requirements_met? is false' do
        allow(subject).to receive(:has_expected_arguments?).and_return(false)
        allow(subject).to receive(:requirements_met?).and_return(false)
        expect(subject.satisfied?('blorf')).to be_falsey
      end
    end

    describe '.args_have_keys?(args, keys)' do

      it 'args have all keys in the list of keys' do
        expect(subject.args_have_keys?({ this: 'this', nest1: { nest2: { that: 'that' } } }, [:this, :that])).to be_truthy
      end

      it 'args missing a key in the list of keys' do
        expect(subject.args_have_keys?({ this: 'this', nest1: { nest2: { that: 'that' } } }, [:this, :that, :blorf])).to be_falsey
      end

      describe 'nil or empty list of keys is always true' do

        key_variations = { 'nil': nil, 'empty': [] }

        key_variations.each do |key_desc, key_value|

          describe "keys is #{key_desc}" do
            it 'args is nil' do
              expect(subject.args_have_keys?(nil, key_value)).to be_truthy
            end

            it 'args is empty' do
              expect(subject.args_have_keys?({}, key_value)).to be_truthy
            end

            it 'args is not empty' do
              expect(subject.args_have_keys?({ this: 'that' }, key_value)).to be_truthy
            end
          end # describe "keys is #{key_desc}"
        end

      end

      describe 'false if there are required keys and args is empty or nil' do

        it 'args is nil' do
          expect(subject.args_have_keys?(nil, [:required_key])).to be_falsey
        end

        it 'args is empty' do
          expect(subject.args_have_keys?({}, [:required_key])).to be_falsey
        end
      end

    end

    describe 'subclasses must define; raises NoMethodError' do

      it '.has_expected_arguments?(_args)' do
        expect { subject.has_expected_arguments?({}) }.to raise_error NoMethodError
      end

      it '.requirements_met?(_args)' do
        expect { subject.requirements_met?({}) }.to raise_error NoMethodError
      end

    end
  end
end
