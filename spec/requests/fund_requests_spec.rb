require "rails_helper"

RSpec.describe FundRequestsController, type: :request do
  describe "GET /casa_cases/:casa_id/fund_request/new" do
    context "when volunteer" do
      context "when casa_case is within organization" do
        it "is successful" do
          volunteer = create(:volunteer, :with_casa_cases)
          casa_case = volunteer.casa_cases.first

          sign_in volunteer
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa case is not within organization" do
        it "redirects to root" do
          volunteer = create(:volunteer)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in volunteer
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when supervisor" do
      context "when casa_case is within organization" do
        it "is successful" do
          org = create(:casa_org)
          supervisor = create(:supervisor, casa_org: org)
          casa_case = create(:casa_case, casa_org: org)

          sign_in supervisor
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa_case is not within organization" do
        it "redirects to root" do
          supervisor = create(:supervisor)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in supervisor
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when admin" do
      context "when casa_case is within organization" do
        it "is successful" do
          org = create(:casa_org)
          admin = create(:casa_admin, casa_org: org)
          casa_case = create(:casa_case, casa_org: org)

          sign_in admin
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa_case is not within organization" do
        it "redirects to root" do
          admin = create(:casa_admin)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in admin
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe "POST /casa_cases/:casa_id/fund_request" do
    context "when volunteer" do
      context "when casa_case is within organization" do
        context "with valid params" do
          it "creates fund request, calls mailer, and redirects to casa case" do
            volunteer = create(:volunteer, :with_casa_cases)
            casa_case = volunteer.casa_cases.first
            mailer_mock = double("mailer", deliver: nil)

            sign_in volunteer

            expect(FundRequestMailer).to receive(:send_request).with(nil, instance_of(FundRequest)).and_return(mailer_mock)
            expect(mailer_mock).to receive(:deliver)
            expect {
              post casa_case_fund_request_path(casa_case), params: {
                submitter_email: "foo@example.com",
                youth_name: "CINA-123",
                payment_amount: "$10.00",
                deadline: "2022-12-31",
                request_purpose: "something noble",
                payee_name: "Minnie Mouse",
                requested_by_and_relationship: "Favorite Volunteer",
                other_funding_source_sought: "Some other agency",
                impact: "Great",
                extra_information: "foo bar"
              }
            }.to change(FundRequest, :count).by(1)

            fr = FundRequest.last
            expect(fr.submitter_email).to eq "foo@example.com"
            expect(fr.youth_name).to eq "CINA-123"
            expect(fr.payment_amount).to eq "$10.00"
            expect(fr.deadline).to eq "2022-12-31"
            expect(fr.request_purpose).to eq "something noble"
            expect(fr.payee_name).to eq "Minnie Mouse"
            expect(fr.requested_by_and_relationship).to eq "Favorite Volunteer"
            expect(fr.other_funding_source_sought).to eq "Some other agency"
            expect(fr.impact).to eq "Great"
            expect(fr.extra_information).to eq "foo bar"
            expect(response).to redirect_to casa_case
          end
        end

        context "with in valid params" do
          it "does not create fund request or call mailer" do
            volunteer = create(:volunteer, :with_casa_cases)
            casa_case = volunteer.casa_cases.first
            allow_any_instance_of(FundRequest).to receive(:save).and_return(false)

            sign_in volunteer
            expect(FundRequestMailer).to_not receive(:send_request)
            expect {
              post casa_case_fund_request_path(casa_case), params: {
                submitter_email: "foo@example.com",
                youth_name: "CINA-123",
                payment_amount: "$10.00",
                deadline: "2022-12-31",
                request_purpose: "something noble",
                payee_name: "Minnie Mouse",
                requested_by_and_relationship: "Favorite Volunteer",
                other_funding_source_sought: "Some other agency",
                impact: "Great",
                extra_information: "foo bar"
              }
            }.to_not change(FundRequest, :count)

            expect(response).to be_successful
          end
        end
      end

      context "when casa_case is not within organization" do
        it "does not create fund request or call mailer" do
          volunteer = create(:volunteer, :with_casa_cases)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in volunteer
          expect(FundRequestMailer).to_not receive(:send_request)
          expect {
            post casa_case_fund_request_path(casa_case), params: {
              submitter_email: "foo@example.com",
              youth_name: "CINA-123",
              payment_amount: "$10.00",
              deadline: "2022-12-31",
              request_purpose: "something noble",
              payee_name: "Minnie Mouse",
              requested_by_and_relationship: "Favorite Volunteer",
              other_funding_source_sought: "Some other agency",
              impact: "Great",
              extra_information: "foo bar"
            }
          }.to_not change(FundRequest, :count)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when supervisor" do
      it "creates fund request, calls mailer, and redirects to casa case" do
        supervisor = create(:supervisor)
        casa_case = create(:casa_case)
        mailer_mock = double("mailer", deliver: nil)

        sign_in supervisor

        expect(FundRequestMailer).to receive(:send_request).with(nil, instance_of(FundRequest)).and_return(mailer_mock)
        expect(mailer_mock).to receive(:deliver)
        expect {
          post casa_case_fund_request_path(casa_case), params: {
            submitter_email: "foo@example.com",
            youth_name: "CINA-123",
            payment_amount: "$10.00",
            deadline: "2022-12-31",
            request_purpose: "something noble",
            payee_name: "Minnie Mouse",
            requested_by_and_relationship: "Favorite Volunteer",
            other_funding_source_sought: "Some other agency",
            impact: "Great",
            extra_information: "foo bar"
          }
        }.to change(FundRequest, :count).by(1)

        expect(response).to redirect_to casa_case
      end
    end

    context "when admin" do
      it "creates fund request, calls mailer, and redirects to casa case" do
        admin = create(:casa_admin)
        casa_case = create(:casa_case)
        mailer_mock = double("mailer", deliver: nil)

        sign_in admin

        expect(FundRequestMailer).to receive(:send_request).with(nil, instance_of(FundRequest)).and_return(mailer_mock)
        expect(mailer_mock).to receive(:deliver)
        expect {
          post casa_case_fund_request_path(casa_case), params: {
            submitter_email: "foo@example.com",
            youth_name: "CINA-123",
            payment_amount: "$10.00",
            deadline: "2022-12-31",
            request_purpose: "something noble",
            payee_name: "Minnie Mouse",
            requested_by_and_relationship: "Favorite Volunteer",
            other_funding_source_sought: "Some other agency",
            impact: "Great",
            extra_information: "foo bar"
          }
        }.to change(FundRequest, :count).by(1)

        expect(response).to redirect_to casa_case
      end
    end
  end
end
