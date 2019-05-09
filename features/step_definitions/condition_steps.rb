# Steps involved with Conditions

LOG = 'log/test-conditions.log'

def condition
  @condition ||=  new_condition
end

def new_condition
  c = Condition.new
  c.config = {}
  c
end



And("the process_condition task sends {capture_string} to the {capture_string} class") do |method, klass|

  ActivityLogger.open(LOG, 'SHF_TASK', 'Conditions') do |log|

    alert_klass = klass.constantize
    alert_klass.send(method.to_sym, @condition, log) if klass

  end # ActivityLogger
end


And("there is a condition with class_name {capture_string} and timing {capture_string}") do |klass_name, timing|

  condition.class_name = klass_name
  condition.timing     = timing.to_sym
end


And("the condition has starting date set to {date}") do | starting_date |
  condition.config[:starting_date] = starting_date
end


And(/the condition has days set to \[(?:(.*),)(.*)\]/) do |days_list, last_day|
  days_arr = []
  days_arr = days_list.split(',').map(&:to_i) unless days_list.nil?

  days_arr << last_day.to_i
  condition.config[:days] = days_arr
end

And("the condition has the month day set to {digits}") do | month_day |
  condition.config[:on_month_day] = month_day
end

#==================================================================================
#
# Assertions


Then(/^the condition days includes (\d+)$/) do |day_number|
  expect(condition.config[:days]).to include day_number
end
