# Fetch dinkurs events

class DinkursFetch < ConditionResponder

  def self.condition_response(condition, log)

    confirm_correct_timing(get_timing(condition), TIMING_EVERY_DAY, log)

    Company.with_dinkurs_id.each do |company|

      company.fetch_dinkurs_events
      company.reload
      log.record('info', "Company #{company.id}: #{company.events.count} events.")

    end

  end

end
