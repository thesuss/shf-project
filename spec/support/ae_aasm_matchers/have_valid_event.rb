# from aasm README.md:
# # show all events
# Job.aasm.events.map(&:name)

private def blank?(something)
  something.nil? || (something.respond_to?(:empty?) ? !!something.empty? : !something)
end


RSpec::Matchers.define :have_valid_event do |event|
  match do |obj|
    @state_machine_name ||= :default
    blank?(event) ? false : obj.aasm(@state_machine_name).events.map(&:name).include?(event)
  end

  chain :for_state_machine do |state_machine_name|
    @state_machine_name = state_machine_name
  end

  description do
    "#{expected} is a valid event (for_state_machine :#{@state_machine_name})"
  end

  failure_message do |obj|
    "expected that :#{expected} is a valid event (for_state_machine :#{@state_machine_name})"
  end

  failure_message_when_negated do |obj|
    "expected that :#{expected} is a not valid event (for_state_machine :#{@state_machine_name})"
  end
end

