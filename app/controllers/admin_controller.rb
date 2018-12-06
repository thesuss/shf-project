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


  def export_str(shf_apps)

    out_str = export_header_str

    shf_apps.each do |m_app|

      app_company = m_app.companies.last

      out_str << "#{m_app.contact_email},#{m_app.user.first_name},#{m_app.user.last_name},#{m_app.user.membership_number},"
      out_str << t("shf_applications.state.#{m_app.state}")
      out_str << ','

      # state date
      out_str << (m_app.updated_at.strftime('%F'))
      out_str << ','

      # add the business categories, all surrounded by double-quotes
      out_str << '"' + m_app.business_categories.map(&:name).join(', ') + '"'
      out_str << ','

      # a company name may have commas, so surround with quotes so spreadsheets recognize it as one string and not multiple comma-separated value
      out_str << (m_app.companies.empty? ? '' : "\"#{app_company.name}\"")
      out_str << ','

      out_str << '"' + paid_M_or_link(m_app) + '",'

      # membership expiry date
      out_str << '"' + (never_paid_if_blank(m_app.user.membership_expire_date)) + '",'

      if m_app.companies.empty?
        out_str << "-,#{t('admin.export_ansokan_csv.never_paid')},"
      else
        out_str << '"' + paid_H_or_link(m_app) + '",'
        # H brand expiry date
        out_str << '"' + (never_paid_if_blank(app_company.branding_expire_date)) + '",'
      end

      # add the SE postal service mailing address info as a CSV string
      out_str << m_app.se_mailing_csv_str


      out_str << "\n"
    end

    out_str.encode('UTF-8')
  end


  def export_header_str

    # build the header string from strings in the locale file

    header_member_strs = [t('activerecord.attributes.shf_application.contact_email'),
                          t('activerecord.attributes.shf_application.first_name'),
                          t('activerecord.attributes.shf_application.last_name'),
                          t('activerecord.attributes.user.membership_number'),
                          t('activerecord.attributes.shf_application.state'),
                          'date of state',
                          t('activerecord.models.business_category.other'),
                          t('activerecord.models.company.one'),
                          'Member fee',
                          t('admin.export_ansokan_csv.member_fee_expires'),
                          'H-branding',
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


  def paid_H_or_link (arg)
    if arg.companies.empty?
      '-'
    else
      paid_or_payment_link(arg.companies.last&.branding_license?, company_path(arg.companies.last.id))
    end
  end


  def paid_M_or_link (arg)
    paid_or_payment_link(arg.user.membership_current?, user_path(arg.user))
  end


  # t('Paid') if member fee is paid, otherwise make link to where to pay it
  def paid_or_payment_link(is_paid, payment_url)
    is_paid ? t('admin.export_ansokan_csv.paid') : t('admin.export_ansokan_csv.fee_payment_url', payment_url: payment_url)
  end


  # return 'never paid' if arg isNil else the arg.to_s
  def never_paid_if_blank(arg)
    arg.blank? ? t('admin.export_ansokan_csv.never_paid') : arg.to_s
  end

end
