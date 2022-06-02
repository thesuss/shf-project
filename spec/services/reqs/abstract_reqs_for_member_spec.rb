# frozen_string_literal: true

require 'spec_helper'
require_relative File.join('..', '..', '..', 'app', 'services', 'reqs', 'abstract_requirements')
require_relative File.join('..', '..', '..', 'app', 'services', 'reqs', 'abstract_reqs_for_member')

require 'active_support/core_ext/date/calculations' # required for Date.current

module Reqs
  RSpec.describe AbstractReqsForMember do
    let(:subject) { AbstractReqsForMember }

    let(:entity) { 'This is some entity' }

    describe '.requirements_met?' do

      it 'uses Date.current if there is no date given' do
        date_current = Date.current

        expect(subject).to receive(:requirements_excluding_payments_met?).with(entity, date_current).and_return(true)
        expect(subject).to receive(:payment_requirements_met?).with(entity, date_current).and_return(true)
        expect(subject.requirements_met?(entity: entity)).to be_truthy
      end

      it 'all non-payment requirements (for the entity on the date) && all payment requirements (for the entity on the date)' do
        given_date = Date.new
        expect(subject).to receive(:requirements_excluding_payments_met?).with(entity, given_date).and_return(true)
        expect(subject).to receive(:payment_requirements_met?).with(entity, given_date).and_return(true)
        expect(subject.requirements_met?(entity: entity, date: given_date)).to be_truthy
      end
    end

    describe 'subclasses must define these methods; raises NoMethodError if not' do

      it '.requirements_excluding_payments_met?' do
        expect { subject.requirements_excluding_payments_met? }.to raise_error(NoMethodError, /Subclass must define the requirements_excluding_payments_met\? method/)
      end

      it '.payment_requirements_met?' do
        expect { subject.payment_requirements_met? }.to raise_error(NoMethodError, /Subclass must define the payment_requirements_met\? method/)
      end
    end
  end
end
