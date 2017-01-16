# from aasm README.md:
# # show all states
# Job.aasm.states.map(&:name)

module AE_AASM_Matchers
  def self.blank?(something)
    something.nil? || (something.respond_to?(:empty?) ? !!something.empty? : !something)
  end
end

RSpec::Matchers.define :have_valid_state do |state|
  match do |obj|
    @state_machine_name ||= :default
    AE_AASM_Matchers.blank? blank?(state) ? false : obj.class.aasm(@state_machine_name).states.map(&:name).include?(state)
  end

  chain :for_state_machine do |state_machine_name|
    @state_machine_name = state_machine_name
  end

  description do
    "#{expected} is a valid state (for_state_machine :#{@state_machine_name})"
  end

  failure_message do |obj|
    "expected :#{expected} to be a valid state (for_state_machine :#{@state_machine_name})"
  end

  failure_message_when_negated do |obj|
    "expected :#{expected} to not be a valid state (for_state_machine :#{@state_machine_name})"
  end
end
