# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API::Users::IpActivities", type: :request do
  let(:user) { create(:user) }
  let(:trading_account) { create(:trading_account, user: user) }
  let(:ip_activity) { create(:ip_activity, user: user) }
  let(:trading_account_ip_activity) { create(:ip_activity, trading_account: trading_account) }

  before do
    ip_activity
    trading_account_ip_activity
  end

  describe "GET /api/users/:user_id/ip_activities" do
    subject { get "/api/users/#{user.id}/ip_activities", params: }

    let(:params) { {} }

    it "returns a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "returns the correct IP activities" do
      subject
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(2)
      expect(json_response.map { |a| a["id"] }).to match_array([ip_activity.id, trading_account_ip_activity.id])
    end

    context "with date range filter" do
      let(:params) do
        {
          created_at_from: 1.week.ago.rfc3339,
          created_at_to: Time.current.rfc3339
        }
      end

      it "returns a successful response" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "with phase filter" do
      let(:params) { { phase: "student,practitioner" } }

      it "returns a successful response" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "with platform filter" do
      let(:params) { { platform: "mt5,matchtrader" } }

      it "returns a successful response" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "with activity type filter" do
      let(:params) { { activity_type: "kyc,trade" } }

      it "returns a successful response" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "with trading_account_login filter" do
      let(:params) { { trading_account_login: trading_account.login } }

      it "returns a successful response" do
        subject
        expect(response).to have_http_status(:ok)
      end

      it "returns only activities with matching trading_account_login" do
        subject
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(1)
        expect(json_response.first["id"]).to eq(trading_account_ip_activity.id)
      end
    end

  end

  describe "GET /api/users/:user_id/ip_activities/filter_metadata" do
    subject { get "/api/users/#{user.id}/ip_activities/filter_metadata", params: }

    let(:params) { {} }

    it "returns a successful response" do
      subject
      expect(response).to have_http_status(:ok)
    end

    it "returns the correct metadata" do
      subject
      json_response = JSON.parse(response.body)
      expect(json_response).to include(
        "ip_activities_count",
        "trading_account_logins",
        "activity_types",
        "phases",
        "platforms"
      )
    end

  end
end
