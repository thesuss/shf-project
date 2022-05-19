require 'rails_helper'

module Alerts

  # TODO this shows that refactoring of the classes/objects used is needed!
  RSpec.describe ShfAppNoUploadedFilesAlert do

    let(:subject) { described_class.instance }

    # don't write anything to the log
    let(:mock_log) { instance_double("ActivityLogger") }
    before(:each) do
      allow(ActivityLogger).to receive(:new).and_return(mock_log)
      allow(mock_log).to receive(:info)
      allow(mock_log).to receive(:record)
      allow(mock_log).to receive(:close)
    end

    describe 'Unit tests' do

      describe '.send_alert_this_day?(config, user)' do
        let(:timing) { described_class.timing_after }

        let(:applicant) { instance_double("User") }
        let(:mock_shf_app) { instance_double("ShfApplication") }

        before(:each) do
          allow(applicant).to receive(:shf_application)
                                .and_return(mock_shf_app)
        end

        it 'false if no application' do
          allow(applicant).to receive(:has_shf_application?)
                                .and_return(false)
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end

        it 'false if application is not waiting for files' do
          allow(applicant).to receive(:has_shf_application?)
                                .and_return(true)

          allow(mock_shf_app).to receive(:possibly_waiting_for_upload?)
                                   .and_return(false)
          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end

        it 'false if at least 1 file was uploaded' do
          allow(applicant).to receive(:has_shf_application?)
                                .and_return(true)
          allow(mock_shf_app).to receive(:possibly_waiting_for_upload?)
                                   .and_return(true)
          allow(mock_shf_app).to receive(:uploaded_files)
                                   .and_return(['something'])

          expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
        end

        context 'no files were uploaded' do
          let(:mock_file_delivery_now) { instance_double('AdminOnly::FileDeliveryMethod', name: 'upload_now') }
          let(:mock_file_delivery_email) { instance_double('AdminOnly::FileDeliveryMethod', name: 'email') }
          let(:mock_file_delivery_mail) { instance_double('AdminOnly::FileDeliveryMethod', name: 'mail') }

          before(:each) do
            allow(applicant).to receive(:has_shf_application?)
                                  .and_return(true)
            allow(mock_shf_app).to receive(:possibly_waiting_for_upload?)
                                     .and_return(true)
            allow(mock_shf_app).to receive(:uploaded_files)
                                     .and_return([])
            allow(mock_file_delivery_now).to receive(:email?)
                                               .and_return(false)
            allow(mock_file_delivery_now).to receive(:email?)
                                               .and_return(false)
          end

          it 'false if user will send the files later' do
            allow(mock_shf_app).to receive(:upload_files_will_be_delivered_later?)
                                     .and_return(true)

            expect(described_class.instance.send_alert_this_day?(timing, config, applicant)).to be_falsey
          end

          context 'user did not indicate they would send them later' do

            it "uses the application's date last updated as the basis for the 'days away from today" do
              allow(mock_shf_app).to receive(:upload_files_will_be_delivered_later?)
                                       .and_return(false)

              shf_last_updated_date = DateTime.now
              allow(mock_shf_app).to receive(:updated_at)
                                       .and_return(shf_last_updated_date)

              expect(described_class).to receive(:days_today_is_away_from)
                                           .with(shf_last_updated_date.to_date, timing)
                                           .and_return(1)

              allow(subject).to receive(:send_on_day_number?)
                                  .with(1, config)
                                  .and_return(true)
              expect(subject.send_alert_this_day?(timing, config, applicant)).to be_truthy
            end

            it 'uses send_on_day_number? to see if the alert should be sent' do
              allow(mock_shf_app).to receive(:upload_files_will_be_delivered_later?)
                                       .and_return(false)
              shf_last_updated_date = DateTime.now
              allow(mock_shf_app).to receive(:updated_at)
                                       .and_return(shf_last_updated_date)
              allow(described_class).to receive(:days_today_is_away_from)
                                          .with(shf_last_updated_date.to_date, timing)
                                          .and_return(1)

              expect(subject).to receive(:send_on_day_number?)
                                   .with(1, config)
                                   .and_return(true)

              expect(subject.send_alert_this_day?(timing, config, applicant)).to be_truthy
            end

          end

        end

      end

      it '.mailer_method' do
        expect(described_class.instance.mailer_method).to eq :app_no_uploaded_files
      end
    end

    describe 'Integration tests' do

      describe 'emails all applicants that need to upload files for their application' do

        context 'timing is after' do
          let(:timing) { described_class.timing_after }

          context 'config days: [10, 20]' do
            let(:config_10_2) { { days: [10, 20] } }
            let(:condition) { build(:condition, timing: timing, config: config_10_2) }

            let(:date_last_updated) { DateTime.new(2020, 8, 1) }

            let(:mock_app1) { instance_double("ShfApplication", updated_at: date_last_updated) }
            let(:mock_member1) { instance_double("User", shf_application: mock_app1) }
            let(:mock_app2) { instance_double("ShfApplication", updated_at: date_last_updated) }
            let(:mock_member2) { instance_double("User", shf_application: mock_app2) }

            before(:each) do
              allow(subject).to receive(:entities_to_check)
                                  .and_return([mock_member1, mock_member2])

              allow(mock_member1).to receive(:has_shf_application?)
                                       .and_return(true)
              allow(mock_member2).to receive(:has_shf_application?)
                                       .and_return(true)
              allow(mock_app1).to receive(:possibly_waiting_for_upload?)
                                    .and_return(true)
              allow(mock_app2).to receive(:possibly_waiting_for_upload?)
                                    .and_return(true)
              allow(mock_app1).to receive(:uploaded_files)
                                    .and_return([])
              allow(mock_app2).to receive(:uploaded_files)
                                    .and_return([])
              allow(mock_app1).to receive(:upload_files_will_be_delivered_later?)
                                    .and_return(false)
              allow(mock_app2).to receive(:upload_files_will_be_delivered_later?)
                                    .and_return(false)
            end

            context 'today is 20 days since they last updated their application' do
              let(:testing_today) { date_last_updated + 20.days }

              it 'email sent to each applicant that needs to upload files' do

                expect(described_class).to receive(:days_today_is_away_from)
                                             .with(date_last_updated.to_date, timing)
                                             .twice
                                             .and_call_original

                expect(subject).to receive(:send_email)
                                     .with(mock_member1, mock_log)
                expect(subject).to receive(:send_email)
                                     .with(mock_member2, mock_log)

                travel_to testing_today do
                  subject.condition_response(condition, mock_log)
                end
              end
            end

            context 'today is 19 days since they last updated their application' do
              let(:testing_today) { date_last_updated + 19.days }

              it 'no email sent' do
                expect(described_class).to receive(:days_today_is_away_from)
                                             .with(date_last_updated.to_date, timing)
                                             .twice
                                             .and_call_original

                expect(subject).not_to receive(:send_email)
                travel_to testing_today do
                  subject.condition_response(condition, mock_log)
                end
              end
            end
          end
        end
      end
    end
  end
end
