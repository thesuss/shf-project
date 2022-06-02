require 'rails_helper'

module Reqs
  RSpec.describe AbstractReqsForMembership do
    let(:subject) { AbstractReqsForMembership }
    let(:entity) { build(:user) }

    describe '.requirements_excluding_payments_met?' do

      it 'subclasses must define this; raises NoMethodError' do
        expect { subject.requirements_excluding_payments_met?({}) }.to raise_error NoMethodError
      end
    end

    describe '.payment_requirements_met?' do

      it 'result = user.payments_current_as_of?' do
        entity = build(:user)
        expect(entity).to receive(:payments_current_as_of?).and_return(true)
        expect(subject.payment_requirements_met?(entity)).to be_truthy

        expect(entity).to receive(:payments_current_as_of?).and_return(false)
        expect(subject.payment_requirements_met?(entity)).to be_falsey
      end

      it 'for a specific date: it passes that date to payments_current_as_of?' do
        entity = build(:user)
        yesterday = Date.current - 1.day
        expect(entity).to receive(:payments_current_as_of?)
                            .with(yesterday).and_return(true)
        expect(subject.payment_requirements_met?(entity, yesterday)).to be_truthy
        expect(entity).to receive(:payments_current_as_of?)
                            .with(yesterday).and_return(false)
        expect(subject.payment_requirements_met?(entity, yesterday)).to be_falsey
      end
    end
  end
end
