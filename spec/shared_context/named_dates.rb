# Dates that can be used in examples, tests, etc.
#
# Use:
#  require 'shared_context/named_dates'
#
#  within a 'describe' or 'context' block:
#   include_context 'named dates'
#
RSpec.shared_context 'named dates' do

  THIS_YEAR = 2018 unless defined?(THIS_YEAR)

  let(:jan_1) { Time.zone.local(2018, 1, 1) }
  let(:jan_2) { Time.zone.local(2018, 1, 2) }
  let(:jan_3) { Time.zone.local(2018, 1, 3) }
  let(:jan_30) { Time.zone.local(THIS_YEAR, 1, 30) }
  let(:jan_31) { Time.zone.local(THIS_YEAR, 1, 31) }

  let(:feb_1) { Time.zone.local(THIS_YEAR, 2, 1) }
  let(:feb_2) { Time.zone.local(THIS_YEAR, 2, 2) }
  let(:feb_3) { Time.zone.local(THIS_YEAR, 2, 3) }

  let(:jul_1) { Time.zone.local(THIS_YEAR, 7, 1) }

  let(:nov_29) { Time.zone.local(THIS_YEAR, 11, 29) }
  let(:nov_30) { Time.zone.local(THIS_YEAR, 11, 30) }

  let(:dec_1) { Time.zone.local(THIS_YEAR, 12, 1) }
  let(:dec_2) { Time.zone.local(THIS_YEAR, 12, 2) }
  let(:dec_3) { Time.zone.local(THIS_YEAR, 12, 3) }
  let(:dec_5) { Time.zone.local(THIS_YEAR, 12, 5) }
  let(:dec_31) { Time.zone.local(2018, 12, 31) }

  #
  # Last year
  #
  let(:lastyear_nov_29) { Time.zone.local(THIS_YEAR - 1, 11, 29) }
  let(:lastyear_nov_30) { Time.zone.local(THIS_YEAR - 1, 11, 30) }

  let(:lastyear_dec_1) { Time.zone.local(THIS_YEAR - 1, 12, 1) }
  let(:lastyear_dec_2) { Time.zone.local(THIS_YEAR - 1, 12, 2) }
  let(:lastyear_dec_3) { Time.zone.local(THIS_YEAR - 1, 12, 3) }
  let(:lastyear_dec_8) { Time.zone.local(THIS_YEAR - 1, 12, 8) }
  let(:lastyear_dec_9) { Time.zone.local(THIS_YEAR - 1, 12, 9) }
  let(:lastyear_dec_10) { Time.zone.local(THIS_YEAR - 1, 12, 10) }

  #
  # Next year
  #

  let(:nextyear_nov_29) { Time.zone.local(THIS_YEAR + 1, 11, 29) }
  let(:nextyear_nov_30) { Time.zone.local(THIS_YEAR + 1, 11, 30) }

end
