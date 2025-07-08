# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from StandardError, with: :internal_server_error

    private

    def not_found
      render json: { error: "Record not found" }, status: :not_found
    end

    def internal_server_error(exception)
      Rails.logger.error(exception)
      render json: { error: "Internal server error" }, status: :internal_server_error
    end
  end
end
