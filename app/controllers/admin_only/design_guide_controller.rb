module AdminOnly


  class DesignGuideController < AdminOnlyController


    def show

      # need to have some models to work with to demo buttons, links, etc.
      @company                 = Company.first
      @all_business_categories = BusinessCategory.all

    end


    private


    # Never trust parameters from the scary internet, only allow the white list through.
    def admin_only_design_guide_params
      params.fetch(:admin_only_design_guide, {})
    end
  end

end
