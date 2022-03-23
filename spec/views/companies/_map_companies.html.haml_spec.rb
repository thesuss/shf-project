require 'rails_helper'

class TempCompanyHelper
  include CompaniesHelper
end

RSpec.describe "company maps partial: _map_companies.html.haml" do

  it "map markers are raw json (not escaped)" do

    test_companies = []
    test_companies << create(:company)

    render partial: 'companies/map_companies.html.haml',
           locals: {markers: TempCompanyHelper.new.location_and_markers_for(test_companies, link_name: false)}

    expect(rendered).to include("var markers = [{\"latitude\":56.7422437,\"longitude\":12.7206453,")

    expect(rendered).not_to match %r(var markers =(.*)&quot;longitude)
  end

end
