# frozen_string_literal: true

module V1
  class ReportsController < ApplicationController
    before_action :authenticate_user!

    def index
      param! :start, Time, required: true
      param! :end, Time, required: true
      param! :period, String, required: true
      param! :time_zone, String

      render json: Report.new(
        user: current_user,
        range: params[:start]..params[:end],
        period: params[:period],
        time_zone: params[:time_zone]
      )
    end
  end
end
