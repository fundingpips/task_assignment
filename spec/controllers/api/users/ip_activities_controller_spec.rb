# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Users::IpActivitiesController do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:trading_account) { create(:trading_account, user: user, phase: "master", platform: "tradelocker") }

  let(:ip_address) { create(:ip_address).address }
  let(:ip_activities) do
    [
      create(:ip_activity, user: user, ip_address: ip_address, created_at: 1.day.ago, activity_type: "kyc"),
      create(:ip_activity, trading_account: trading_account, ip_address: ip_address, created_at: 2.days.ago, activity_type: "kyc")
    ]
  end

  # Should not be returned by the API
  let(:irrelevant_ip_activities) { create_list(:ip_activity, 3, user: other_user, activity_type: "kyc") }

  before do
    ip_activities
    irrelevant_ip_activities
  end

  describe "#index" do
    subject(:index) { get :index, params: }

    let(:params) { { user_id: user.id } }
    let(:json_response) { response.parsed_body }

    it "renders the index successfully" do
      index

      expect(response).to be_ok
    end

    it "returns the correct JSON structure" do
      index

      expect(json_response.size).to eq(2)
      expect(json_response.map { |a| a["id"] }).to match_array(ip_activities.map(&:id))
    end

    context "with limit" do
      let(:trade_activities) { create_list(:ip_activity, 6, ip_address: ip_address, trading_account: trading_account) }
      let!(:kyc_activity) { create(:ip_activity, :kyc, ip_address: ip_address, user: user) }
      let(:limit) { 5 }

      before do
        trade_activities
        stub_const("#{described_class}::LIMIT", limit)
      end

      it "returns limited records per activity type" do
        index
        received_ids = json_response.map { |activity| activity["id"] }
        expect(received_ids).to include(kyc_activity.id)

        trade_type = json_response.filter { |activity| activity["activity_type"] == "trade" }
        expect(trade_type.count).to eq(limit)
      end
    end

    context "when has filter by date" do
      let(:recent_ip_activity) { create(:ip_activity, user: user, created_at: Time.zone.tomorrow) }
      let(:params) { { user_id: user.id, created_at_from: Time.zone.tomorrow } }

      it "applies filters correctly" do
        recent_ip_activity
        index

        expect(json_response.size).to eq(1)
        expect(json_response.first["id"]).to eq(recent_ip_activity.id)
      end
    end

    context "when filtering by activity_type" do
      let!(:trade_activity) { create(:ip_activity, user: user, activity_type: "trade") }
      let!(:login_activity) { create(:ip_activity, user: user, activity_type: "login") }
      let(:kyc_activity) { create(:ip_activity, user: user, activity_type: "kyc") }

      let(:params) { { user_id: user.id, activity_type: %w[trade login] } }

      it "returns activities with the specified activity types" do
        index

        returned_ids = json_response.pluck("id")
        returned_types = json_response.pluck("activity_type")

        expect(returned_ids).to contain_exactly(trade_activity.id, login_activity.id)
        expect(returned_types).to contain_exactly("trade", "login")
      end
    end

    context "when filtering by phase" do
      let!(:trading_account_student) { create(:trading_account, user: user, phase: "student") }
      let!(:trading_account_practitioner) { create(:trading_account, user: user, phase: "practitioner") }

      let!(:ip_activity_student) { create(:ip_activity, trading_account: trading_account_student) }
      let!(:ip_activity_practitioner) { create(:ip_activity, trading_account: trading_account_practitioner) }

      let(:params) { { user_id: user.id, phase: %w[student practitioner] } }

      it "returns activities with matching phases" do
        index

        returned_ids = json_response.pluck("id")
        expect(returned_ids).to contain_exactly(ip_activity_student.id, ip_activity_practitioner.id)
      end
    end

    context "when filtering by platform" do
      let!(:trading_account_mt5) { create(:trading_account, user: user, platform: "mt5") }
      let!(:trading_account_matchtrader) { create(:trading_account, user: user, platform: "matchtrader") }

      let!(:ip_activity_mt5) { create(:ip_activity, trading_account: trading_account_mt5) }
      let!(:ip_activity_matchtrader) { create(:ip_activity, trading_account: trading_account_matchtrader) }

      let(:params) { { user_id: user.id, platform: %w[matchtrader mt5] } }

      it "returns activities with matching platforms" do
        index

        returned_ids = json_response.pluck("id")
        expect(returned_ids).to contain_exactly(ip_activity_mt5.id, ip_activity_matchtrader.id)
      end
    end

    context "when filtering by trading_account_login" do
      let!(:trading_account_1) { create(:trading_account, user: user, login: "login1") }
      let!(:trading_account_2) { create(:trading_account, user: user, login: "login2") }
      let!(:ip_activity_1) { create(:ip_activity, trading_account: trading_account_1) }
      let!(:ip_activity_2) { create(:ip_activity, trading_account: trading_account_2) }

      let(:params) { { user_id: user.id, trading_account_login: %w[login1 login2] } }

      it "returns only activities with matching trading_account_logins" do
        index

        ids = json_response.pluck("id")
        logins = json_response.pluck("trading_account_login")

        expect(ids).to contain_exactly(ip_activity_1.id, ip_activity_2.id)
        expect(logins).to contain_exactly("login1", "login2")
      end
    end

    context "when has direction param" do
      let(:params) { { user_id: user.id, direction: "asc" } }

      it "applies direction correctly" do
        index

        expect(json_response.size).to eq(2)
        expect(json_response.first["id"]).to eq(ip_activities.second.id)
        expect(json_response.last["id"]).to eq(ip_activities.first.id)
      end
    end
  end

  describe "#filter_metadata" do
    subject(:request_filter_metadata) { get :filter_metadata, params: }
    let(:json_response) { response.parsed_body }

    context "when the user exists" do
      before do
        create(:ip_activity, user: user, created_at: Time.zone.yesterday)
        create(:ip_activity, user: user, created_at: Time.zone.today)
        create(:ip_activity, trading_account: trading_account)
      end

      let(:params) { { user_id: user.id, created_at_from: Time.zone.yesterday.beginning_of_day, created_at_to: Time.zone.yesterday.end_of_day } }
      let(:expected_response) do
        {
          "ip_activities_count" => 2,
          "trading_account_logins" => IpActivity.unscoped.for_user(user).reorder(nil).distinct.pluck(:trading_account_login).compact,
          "activity_types" => IpActivity.activity_types.keys,
          "phases" => TradingAccount.phases.keys,
          "platforms" => TradingAccount.platforms.keys
        }
      end

      it "applies filters correctly" do
        request_filter_metadata

        expect(response).to be_ok
        expect(json_response).to eq(expected_response)
      end
    end

  end
end
