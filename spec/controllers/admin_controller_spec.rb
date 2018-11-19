require 'rails_helper'

RSpec.describe AdminController, type: :controller do

  # this will bypass Pundit policy access checks so logging in is not necessary
  before(:each) { Warden.test_mode! }

  after(:each) { Warden.test_reset! }

  let(:user) { create(:user) }

  let(:csv_header) { out_str = ''
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.contact_email').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.first_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.last_name').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.user.membership_number').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.shf_application.state').strip}',"
  out_str << "'date of state',"
  out_str << "'#{I18n.t('activerecord.models.business_category.other').strip}',"
  out_str << "'#{I18n.t('activerecord.models.company.one').strip}',"
  out_str << "'Member fee'," # should use I18n.t ? Check with Susanna L.
  out_str << "'#{I18n.t('admin.export_ansokan_csv.member_fee_expires')}',"
  out_str << "'H-branding'," # should use I18n.t ? Check with Susanna L.
  out_str << "'#{I18n.t('admin.export_ansokan_csv.branding_fee_expires')}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.street').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.post_code').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.city').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.kommun').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.region').strip}',"
  out_str << "'#{I18n.t('activerecord.attributes.address.country').strip}'"
  out_str << "\n"
  out_str }


  describe '#export_ankosan_csv' do


    describe 'logged in as admin' do

      it 'content type is text/csv' do

        post :export_ansokan_csv

        expect(response.content_type).to eq 'text/plain'

      end

      it 'filename is Ansokningar-<datetime>.csv' do

        post :export_ansokan_csv

        expect(response.header['Content-Disposition']).to match(/filename=\"Ansokningar-\d\d\d\d-\d\d-\d\d--\d\d-\d\d-\d\d\.csv\"/)
      end


      it 'header line is correct' do

        post :export_ansokan_csv

        expect(response.body).to eq csv_header

      end


      describe 'with 0 membership applications' do

        it 'no membership applications has just the header' do

          post :export_ansokan_csv

          expect(response.body).to eq csv_header

        end

      end


      def paid_or_payment_url(membership_is_current, payment_path)
        membership_is_current ? I18n.t('admin.export_ansokan_csv.paid') : I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: payment_path)
      end


      # return 'never paid' if arg isNil else the arg.to_s
      def never_paid_if_blank(arg)
        arg.blank? ? I18n.t('admin.export_ansokan_csv.never_paid') : arg.to_s
      end


      describe 'with 1 app for each membership state' do

        it 'includes all applications' do

          result_str = csv_header

          # create 1 application in each state
          ShfApplication.aasm.states.each do |app_state|

            u = FactoryBot.create(:user,
                                  first_name: "First#{app_state.name}",
                                  last_name:  "Last#{app_state.name}",
                                  email:      "#{app_state.name}@example.com")

            m = FactoryBot.create :shf_application,
                                  contact_email: "#{app_state.name}@example.com",
                                  state:         app_state.name,
                                  user:          u

            member1_info = "#{m.contact_email},#{u.first_name},#{u.last_name},#{u.membership_number}," + I18n.t("shf_applications.state.#{app_state.name}")


            result_str << member1_info + ','

            # state date
            result_str << (m.updated_at.strftime('%F'))
            result_str << ','
            result_str << ','

            result_str << "\"#{m.business_categories[0].name}\","

            result_str << (m.companies.empty? ? '' : '"' + m.companies.last.name + '"')

            result_str << ','

            # Membership Fee
            # say Paid if member fee is paid, otherwise make link to where it is paid
            result_str << '"' + paid_or_payment_url(u.membership_current?, user_path(u)) + '"'
            result_str << ','
            result_str << '"' + (never_paid_if_blank(m.user.membership_expire_date)) + '",'
            result_str << ','

            # H-branding fee
            if m.companies.empty?
              result_str << "-,#{I18n.t('admin.export_ansokan_csv.never_paid')},"
            else
              # say betald if branding fee is paid, otherwise makes link to where it is paid (when logged in)
              result_str << '"' + paid_or_payment_url(m.companies.last.branding_license?, company_path(m.companies.last.id)) + '"'
              result_str << ','
              result_str << '"' + (never_paid_if_blank(m.user.membership_expire_date)) + '",'
            end


            result_str << m.se_mailing_csv_str + "\n"

          end

          post :export_ansokan_csv

          # 8 lines
          expected_pattern = /(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n(.*)\n/m

          expect(response.body).to match expected_pattern

        end

      end


      describe 'columns correct with simple results' do


        let(:u1) { FactoryBot.create(:user,
                                     first_name:        "u1",
                                     email:             "user1@example.com",
                                     membership_number: '1234567890')
        }

        let(:c1) { FactoryBot.create(:company) }

        let(:membership_app) do
          FactoryBot.create :shf_application,
                            contact_email: "u1@example.com",
                            state:         :accepted,
                            user:          u1
        end

        let(:membership_payment) do
          FactoryBot.create(:payment,
                            status:      'betald',
                            user:        u1,
                            expire_date: Time.zone.parse("2019-11-08"))
        end

        let(:branding_payment) do
          FactoryBot.create(:payment,
                            status:       'betald',
                            user:         u1,
                            company:      membership_app.companies.first,
                            payment_type: Payment::PAYMENT_TYPE_BRANDING,
                            expire_date:  Time.zone.parse("2019-11-08"))
        end


        let(:csv_response) do

          membership_app.save
          membership_payment.save
          branding_payment.save

          post :export_ansokan_csv
          response.body
        end

        let(:expected_pattern) { /(.*)\n(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m }

        let(:pattern_matches) { csv_response.match expected_pattern }

        it 'the result matches the header and expected number of fields' do
          expect(csv_response).to match expected_pattern
        end

        it 'email' do
          expect(pattern_matches[2]).to eq 'u1@example.com'
        end

        it 'first name' do
          expect(pattern_matches[3]).to eq 'u1'
        end

        it 'last name' do
          expect(pattern_matches[4]).to eq 'Lastname'
        end

        it 'membership number' do
          expect(pattern_matches[5]).to eq '1234567890'
        end

        it 'application status' do
          expect(pattern_matches[6]).to eq 'Godkänd'
        end

        it 'date of state (application status last update)' do
          expect(pattern_matches[7]).to eq Date.today.to_s
        end

        it 'company name' do
          expect(pattern_matches[9]).to eq 'SomeCompany'
        end

        it 'membership fee status' do
          expect(pattern_matches[10]).to eq 'Betald'
        end

        it 'membership expiration date' do
          expect(pattern_matches[11]).to eq '2019-11-08'
        end

        it 'branding fee status' do
          expect(pattern_matches[12]).to eq 'Betald'
        end

        it 'branding license expiration date' do
          expect(pattern_matches[13]).to eq '2019-11-08'
        end

        it 'street' do
          expect(pattern_matches[14]).to eq 'Hundforetagarevägen 1'
        end

        it 'post code' do
          expect(pattern_matches[15]).to eq '310 40'
        end

        it 'ort/city' do
          expect(pattern_matches[16]).to eq 'Harplinge'
        end

        it 'kommun' do
          expect(pattern_matches[17]).to eq 'Ale'
        end

        it 'Verksamhetslän/county' do
          expect(pattern_matches[18]).to eq 'MyString'
        end

        it 'country' do
          expect(pattern_matches[19]).to eq 'Sverige'
        end

      end


      describe 'with business categories (surrounded by double quotes)' do

        let(:u1) { FactoryBot.create(:user,
                                     first_name:        "u1",
                                     email:             "user1@example.com",
                                     membership_number: '1234567890')
        }

        let(:c1) { FactoryBot.create(:company) }

        let(:member1) { FactoryBot.create :shf_application,
                                          contact_email: "u1@example.com",
                                          state:         :accepted,
                                          user:          u1
        }

        let(:csv_response) { post :export_ansokan_csv
        response.body
        }

        let(:csv_response_reg) { post :export_ansokan_csv
        response.body
        }
        let(:member1_info) { "#{member1.contact_email},#{u1.first_name},#{u1.last_name},#{u1.membership_number}," + I18n.t("shf_applications.state.#{member1.state}") }


        it 'zero/nil business categories' do

          user_no_categories = FactoryBot.create(:user)

          shf_app_no_categories                     = FactoryBot.create(:shf_application,
                                                                        user: user_no_categories)
          shf_app_no_categories.business_categories = []

          expect(csv_response).to match(/(.*)\n([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^"^,]*),"",(.*),(.*),(.*),(.*),(.*),#{c1.se_mailing_csv_str}/)

        end

        it 'one business category' do

          member1.save

          #expect(csv_response).to match result_str
          expect(csv_response).to match(/(.*),(.*),(.*),(.*),(.*),(.*),\"#{member1.business_categories[0].name}\",(.*),(.*),(.*),(.*),(.*),#{c1.se_mailing_csv_str}/)

        end


        it 'three business categories, each separated by a comma then space' do

          member1.business_categories = [create(:business_category, name: 'Category1')]
          member1.business_categories << create(:business_category, name: 'Category 2')
          member1.business_categories << create(:business_category, name: 'Category the third')

          member1.save

          # results with 3 categories in quotes
          result_regexp = /(.*)\n([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^"^,]*),\"([^"]*)",(.*),(.*),(.*),(.*),(.*),#{c1.se_mailing_csv_str}/
          expect(csv_response_reg).to match result_regexp

          # Check that the categories are as expected:
          match = csv_response_reg.match result_regexp

          # get the categories from the (.*) group -- if there are any
          #   get rid of extra quotes and whitespace
          match.to_a.size > 7 ? categories = match[8].delete('"').split(',').map(&:strip) : categories = []

          # expect all categories to be there, but could be in any order
          expect(categories).to match_array(['Category1', 'Category 2', 'Category the third'])
        end
      end


      describe 'error from send_data is rescued' do

        # status, location, response_body

        let(:error_message) { 'Error. Error. Warning Will Robinson' }

        subject { allow(@controller).to receive(:send_data) { raise StandardError.new(error_message) }

        post :export_ansokan_csv
        }


        it 'redirects to back or the root path' do

          expect(subject).to redirect_to root_path

        end


        it "flashes an error :alert message" do

          error_flash_message = ["#{I18n.t('admin.export_ansokan_csv.error')} [#{error_message}]"]

          expect(subject.request.flash[:alert]).to_not be_nil
          expect(subject.request.flash[:alert]).to eq error_flash_message

        end

      end


      describe 'includes membership expiry date' do


        it "no membership expiry date shows wording and url to pay and 'never paid'" do

          user_with_app = FactoryBot.create(:user_with_membership_app)

          user_app = user_with_app.shf_application
          user_app.save

          post :export_ansokan_csv

          never_paid    = I18n.t('admin.export_ansokan_csv.never_paid')
          pay_using_url = I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: user_path(user_with_app))

          expected_pattern = /(.*)\n(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","(#{pay_using_url})","(#{never_paid})","([^"]*)","([^"]*)","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)/m

          expect(response.body).to match expected_pattern

        end

      end


      describe 'includes H-branding expiry date' do

        it "no H-brand license expiry date shows wording and url to pay and 'never paid'" do

          user_with_app = FactoryBot.create(:user_with_membership_app)

          user_app = user_with_app.shf_application

          user_with_app.save
          user_app.save

          post :export_ansokan_csv

          never_paid    = I18n.t('admin.export_ansokan_csv.never_paid')
          pay_using_url = I18n.t('admin.export_ansokan_csv.fee_payment_url', payment_url: company_path(user_app.companies.last.id))

          expected_pattern = /(.*)\n(.*),(.*),(.*),(.*),(.*),([^"]*),"([^"]*)","([^"]*)","([^"]*)","([^"]*)","(#{pay_using_url})","(#{never_paid})","([^"]*)",'(.*),"([^"]*)",(.*),(.*),(.*)\n/m

          expect(response.body).to match expected_pattern

        end

      end

    end

  end # '#export_ankosan_csv'

end
