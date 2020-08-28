require 'rails_helper'

RSpec.describe FirstMembershipFeeOwedAlert do

  subject { described_class.instance } # just for readability

  # don't write anything to the log
  let(:mock_log) { instance_double("ActivityLogger") }
  before(:each) do
    allow(ActivityLogger).to receive(:new).and_return(mock_log)
    allow(mock_log).to receive(:info)
    allow(mock_log).to receive(:record)
    allow(mock_log).to receive(:close)
  end


  describe 'Unit tests' do

    it 'mailer_method' do
      expect(subject.mailer_method).to eq :first_membership_fee_owed
    end


    describe 'send_alert_this_day?' do
      let(:timing) { described_class.timing_after }
      let(:config) { { days: [3, 5] } }

      let(:mock_applicant) { instance_double("User") }


      it 'false if RequirementsForFirstMembershipFeeOwed.requirements_met? is false' do
        allow(RequirementsForFirstMembershipFeeOwed).to receive(:requirements_met?)
                                                            .and_return(false)

        expect(subject.send_alert_this_day?(timing, config, mock_applicant)).to be_falsey
      end

      context 'RequirementsForFirstMembershipFeeOwed.requirements_met? is true' do
        approved_date = DateTime.new(2020, 8, 1)
        let(:mock_app) { instance_double("ShfApplication", when_approved: approved_date) }

        before(:each) do
          allow(RequirementsForFirstMembershipFeeOwed).to receive(:requirements_met?)
                                                              .and_return(true)
          allow(mock_applicant).to receive(:shf_application)
                                       .and_return(mock_app)
        end


        it 'uses the application when_approved date to determine how many days to count since today' do
          mock_app = instance_double("ShfApplication")
          allow(mock_applicant).to receive(:shf_application)
                                       .and_return(mock_app)
          approved_date = DateTime.new(2020, 8, 1)
          allow(mock_app).to receive(:when_approved)
                                 .and_return(approved_date)

          expect(described_class).to receive(:days_today_is_away_from)
                                         .with(approved_date, timing)
                                         .and_return(3)
          expect(subject.send_alert_this_day?(timing, config, mock_applicant)).to be_truthy
        end

        it 'calls send_on_day_number? to finally determine if it is true or false' do

          allow(described_class).to receive(:days_today_is_away_from)
                                        .with(approved_date, timing)
                                        .and_return(3)

          expect(subject).to receive(:send_on_day_number?)
                                 .with(3, config)
                                 .and_return(true)

          expect(subject.send_alert_this_day?(timing, config, mock_applicant)).to be_truthy
        end
      end

    end
  end


  describe 'Integration tests' do

    describe 'sends alerts to applicants that owe their first membership fee' do

      context 'timing is after' do
        let(:timing) { described_class.timing_after }

        context 'send on days 3 and 5' do
          let(:config) { { days: [3, 5] } }
          let(:condition) { build(:condition, timing: timing, config: config) }


          let(:membership_expiry) { DateTime.new(2020, 12, 1, 6) }

          let(:mock_member_paid) { instance_double("User") }
          let(:mock_applicant1) { instance_double("User", membership_expire_date: membership_expiry) }
          let(:mock_applicant2) { instance_double("User", membership_expire_date: membership_expiry) }

          let(:approved_date) { DateTime.new(2020, 8, 1) }
          let(:mock_app1) { instance_double("ShfApplication", when_approved: approved_date) }
          let(:mock_app2) { instance_double("ShfApplication", when_approved: approved_date) }

          before(:each) do
            allow(subject).to receive(:entities_to_check).and_return([mock_member_paid,
                                                                      mock_applicant1,
                                                                      mock_applicant2])
            allow(mock_applicant1).to receive(:shf_application)
                                          .and_return(mock_app1)
            allow(mock_applicant2).to receive(:shf_application)
                                          .and_return(mock_app1)

            allow(RequirementsForFirstMembershipFeeOwed).to receive(:requirements_met?)
                                                                .with(user: mock_applicant1)
                                                                .and_return(true)
            allow(RequirementsForFirstMembershipFeeOwed).to receive(:requirements_met?)
                                                                .with(user: mock_applicant2)
                                                                .and_return(true)
            allow(RequirementsForFirstMembershipFeeOwed).to receive(:requirements_met?)
                                                                .with(user: mock_member_paid)
                                                                .and_return(false)
          end


          context '3 days after application approval' do
            let(:testing_today) { approved_date + 3.days }

            it 'alerts are sent to applicants still owing membership fees' do
              expect(subject).to receive(:send_email)
                                     .with(mock_applicant1, mock_log)
              expect(subject).to receive(:send_email)
                                     .with(mock_applicant2, mock_log)
              travel_to testing_today do
                subject.condition_response(condition, mock_log)
              end
            end
          end

          context '4 days after application approval' do
            let(:testing_today) { approved_date + 4.days }

            it 'no alerts sent' do
              expect(subject).to receive(:send_on_day_number?)
                                     .with(4, config)
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
