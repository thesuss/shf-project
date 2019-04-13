class AdminController < ApplicationController
  before_action :authorize_admin

  # export shf_appplications
  def export_ansokan_csv

    begin
      @shf_applications = ShfApplication.includes(:user).all

      export_name = "Ansokningar-#{Time.zone.now.strftime('%Y-%m-%d--%H-%M-%S')}.csv"

      send_data(export_str(@shf_applications), filename: export_name, type: "text/plain")

      helpers.flash_message(:notice, t('.success'))

    rescue => e

      helpers.flash_message(:alert, "#{t('.error')} [#{e.message}]")
      redirect_to(request.referer.present? ? :back : root_path)

    end

  end


  private


  def authorize_admin
    AdminPolicy.new(current_user).authorized?
  end


  # Create a comma separated string for all applications, each application is 1 row
  # so that the info can be used by SHF for reporting,
  # to import into other systems, and as
  # checklists (e.g. to see who has/has not got a membership packet yet, etc.)
  #
  # @param shf_apps [Array] - a list of ShfApplications; 1 for each row to be exported
  # @return [String] - the Comma Separated Values (CSV) list, with a header and 1
  #    row of information for each application
  #
  def export_str(shf_apps)

    out_str = export_header_str

    shf_apps.each do |shf_app|
      out_str << Adapters::ShfApplicationToCsvAdapter.new(shf_app).as_target.to_s
      out_str << "\n"
    end

    out_str.encode('UTF-8')
  end


  # build the CSV export header string from strings in the locale file(s)
  def export_header_str

    header_member_strs = [t('activerecord.attributes.shf_application.contact_email'),
                          t('activerecord.attributes.user.email'),
                          t('activerecord.attributes.shf_application.first_name'),
                          t('activerecord.attributes.shf_application.last_name'),
                          t('activerecord.attributes.user.membership_number'),
                          t('activerecord.attributes.user.date_member_packet_sent'),
                          t('activerecord.attributes.shf_application.state'),
                          t('admin.export_ansokan_csv.date_state_changed'),
                          t('activerecord.models.business_category.other'),
                          t('activerecord.models.company.one'),
                          t('admin.export_ansokan_csv.member_fee_paid'),
                          t('admin.export_ansokan_csv.member_fee_expires'),
                          t('admin.export_ansokan_csv.branding_fee_paid'),
                          t('admin.export_ansokan_csv.branding_fee_expires'),
                          t('activerecord.attributes.address.street'),
                          t('activerecord.attributes.address.post_code'),
                          t('activerecord.attributes.address.city'),
                          t('activerecord.attributes.address.kommun'),
                          t('activerecord.attributes.address.region'),
                          t('activerecord.attributes.address.country'),
    ]

    out_str = ''

    out_str << header_member_strs.map { |header_str| "'#{header_str.strip}'" }.join(',')

    out_str << "\n"

  end

end
