require 'rails_helper'

# UpdateAtRange is a module and so cannot be instantiated.
# Payment includes it and so is used to test the class.

RSpec.describe 'UpdateAtRange' do

  let(:class_that_includes) { Payment }
  let(:factory_method) { :payment  }


  let!(:start_date)        { Time.zone.local(2018, 01, 01, 00, 00, 00) }
  let!(:before_start_date) { Time.zone.local(2017, 12, 31, 23, 59, 59) }
  let!(:after_start_date)  { Time.zone.local(2018, 01, 01, 00, 00, 01) }

  let!(:end_date)          { Time.zone.local(2018, 02, 01, 00, 00, 00) }
  let!(:before_end_date)   { Time.zone.local(2018, 01, 31, 23, 59, 59) }
  let!(:after_end_date)    { Time.zone.local(2018, 02, 01, 00, 00, 01) }

  let(:updated_before_start_date) { create(factory_method, updated_at: before_start_date) }
  let(:updated_on_start_date)     { create(factory_method, updated_at: start_date) }
  let(:updated_after_start_date)  { create(factory_method, updated_at: after_start_date) }

  let(:updated_before_end_date)   { create(factory_method, updated_at: before_end_date) }
  let(:updated_on_end_date)       { create(factory_method, updated_at: end_date) }
  let(:updated_after_end_date)    { create(factory_method, updated_at: after_end_date) }


  it 'returns all payments updated on the start_date' do
    updated_on_start_date
    expect(class_that_includes.updated_in_date_range(start_date, end_date)).to include(updated_on_start_date)
  end

  it 'returns all payments updated on the end_date' do
    updated_on_end_date
    expect(class_that_includes.updated_in_date_range(start_date, end_date)).to include(updated_on_end_date)
  end

  it 'returns all payments updated between start_date and end_date' do
    updated_after_start_date
    updated_before_end_date
    expect(class_that_includes.updated_in_date_range(start_date, end_date)).to include(updated_after_start_date, updated_before_end_date)
  end

  it 'does not return payments updated before the start_date' do
    updated_before_start_date
    expect(class_that_includes.updated_in_date_range(start_date, end_date)).not_to include(updated_before_start_date)
  end

  it 'does not return payments updated after the end_date' do
    updated_after_end_date
    expect(class_that_includes.updated_in_date_range(start_date, end_date)).not_to include(updated_after_end_date)
  end

  it ' end_date is nil: returns all where updated_at >= start_date' do
    updated_before_start_date
    updated_on_start_date
    updated_after_start_date
    updated_before_end_date
    updated_on_end_date
    updated_after_end_date

    expect(class_that_includes.updated_in_date_range(start_date, nil)).to match_array([updated_on_start_date,
                                                                                   updated_after_start_date,
                                                                                   updated_before_end_date,
                                                                                   updated_on_end_date,
                                                                                   updated_after_end_date])
  end


  context 'invalid arguments' do
    it 'raises exception if start_date is nil: ArgumentError: bad value for range' do
      expect{class_that_includes.updated_in_date_range(nil, end_date)}.to raise_exception ArgumentError, 'bad value for range'
    end

    it 'raises exception if start_date is not a date: ArgumentError: bad value for range' do
      expect{class_that_includes.updated_in_date_range(99, end_date)}.to raise_exception ArgumentError, 'bad value for range'
    end


    it 'causes a SQL error if start_date is a date exception and end_date a number:' do
      # the SQL statement is only executed if it has a .count or other method chained after it.  That's why .count is included below
      expect{ class_that_includes.updated_in_date_range(start_date, 99).count }.to raise_error ActiveRecord::StatementInvalid
    end

    it 'raises exception if end_date is not a date or a Number: ArgumentError: bad value for range' do
      expect{class_that_includes.updated_in_date_range(start_date, Class)}.to raise_exception ArgumentError, 'bad value for range'
    end
  end

end
