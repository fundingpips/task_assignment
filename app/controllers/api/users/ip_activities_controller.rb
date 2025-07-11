# frozen_string_literal: true

module Api
  module Users
    class IpActivitiesController < Api::BaseController
      DEFAULT_ORDER_FIELD = :created_at
      DEFAULT_ORDER_DIRECTION = :desc
      LIMIT = 1000

      before_action :set_user

      def index
        render json: user_ip_activities
      end

      def filter_metadata
        render json: {
          ip_activities_count: count_user_ip_activities,
          trading_account_logins: trading_account_logins,
          activity_types: IpActivity.activity_types.keys,
          phases: TradingAccount.phases.keys,
          platforms: TradingAccount.platforms.keys
        }
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def user_ip_activities
        ip_activities = ::IpActivity.unscoped.for_user(@user)
                                    .recent_n_per_activity_type(LIMIT)
        apply_filters(ip_activities).reorder(order)
      end

      def count_user_ip_activities
        ip_activities = ::IpActivity.unscoped.for_user(@user)
                                    .recent_n_per_activity_type(LIMIT)
        apply_filters(ip_activities).count
      end

      def trading_account_logins
        IpActivity.unscoped.for_user(@user)
                  .distinct
                  .pluck(:trading_account_login)
                  .compact
      end

      def apply_filters(scope)
        scope = apply_date_filter(scope)
        scope = apply_activity_type_filter(scope)
        scope = apply_phase_filter(scope)
        scope = apply_platform_filter(scope)
        scope = apply_trading_account_login_filter(scope)
        scope
      end

      def apply_date_filter(scope)
        if params[:created_at_from].present?
          scope = scope.where("ip_activities.created_at >= ?", Time.zone.parse(params[:created_at_from]))
        end

        if params[:created_at_to].present?
          scope = scope.where("ip_activities.created_at <= ?", Time.zone.parse(params[:created_at_to]))
        end

        scope
      end

      def apply_activity_type_filter(scope)
        return scope unless params[:activity_type].present?

        activity_types = Array(params[:activity_type])
        activity_types = activity_types.first.split(",") if activity_types.size == 1
        scope.where(activity_type: activity_types)
      end

      def apply_phase_filter(scope)
        return scope unless params[:phase].present?

        phases = Array(params[:phase])
        phases = phases.first.split(",") if phases.size == 1
        scope.joins(:trading_account).where(trading_accounts: { phase: phases })
      end

      def apply_platform_filter(scope)
        return scope unless params[:platform].present?

        platforms = Array(params[:platform])
        platforms = platforms.first.split(",") if platforms.size == 1
        scope.joins(:trading_account).where(trading_accounts: { platform: platforms })
      end

      def apply_trading_account_login_filter(scope)
        return scope unless params[:trading_account_login].present?

        logins = Array(params[:trading_account_login])
        logins = logins.first.split(",") if logins.size == 1
        scope.where(trading_account_login: logins)
      end

      def order
        direction = params[:direction]&.to_sym == :asc ? :asc : :desc
        { DEFAULT_ORDER_FIELD => direction }
      end
    end
  end
end
