#--------------------------
#
# @class UpdatedAtRange
#
# @desc Responsibility: ActiveRecord scope for querying the  updated_at attribute
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   7/11/20
#
#--------------------------
#
module UpdatedAtRange
  extend ActiveSupport::Concern

  included do

    # @param [Object] start_date - the first possible date that updated_at can be. Cannot be nil
    # @param [Object] end_date - the last possible date that updated_at can be.
    #                             If this is nil, will return _all_ objects that were updated starting with the start_date
    #
    # @return all objects where updated_at: >= start date AND updated_at: <= end_date
    def self.updated_in_date_range(start_date, end_date)
      # even though ruby >= 2.7 allows the start of a Range to be empty,
      # ActiveRecord (postgres BETWEEN command) does not.
      raise ArgumentError, "start_date cannot be nil (start_date = #{start_date}, end_date = #{end_date})" if start_date.blank?

      if !!end_date
        where(updated_at: start_date..end_date)
      else
        where('updated_at >= ?', start_date)
      end
    end

  end

end
