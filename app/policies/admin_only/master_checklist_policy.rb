module AdminOnly

  class MasterChecklistPolicy < AdminOnlyPolicy

    def max_list_position?
      show?
    end


    def next_one_based_list_position?
      edit?
    end


    def set_to_no_longer_used?
      edit?
    end


  end

end
