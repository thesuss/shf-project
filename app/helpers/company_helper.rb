module CompanyHelper

  def company_complete?
    company.name != '' && company.region != ''
  end

end
