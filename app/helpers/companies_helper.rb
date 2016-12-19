module CompaniesHelper

  def company_complete? company
    !company.nil? && !company.name.nil? && !company.name.empty? &&
        !company.region.nil? && !company.region.empty?
  end


  def last_category_name company
    company.business_categories.any? ? company.business_categories.last.name : ''
  end


  def list_categories company
    if company.business_categories.any?
      company.business_categories.order(:name).map(&:name).join(" ")
    end
  end
end
