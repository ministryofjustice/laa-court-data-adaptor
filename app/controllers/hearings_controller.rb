# frozen_string_literal: true

class HearingsController < ApplicationController
  def create
    @hearing = HearingRecorder.call(params[:hearing][:id], hearing_params)

    if @hearing
      render json: @hearing, status: :created
    else
      render json: @hearing.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def hearing_params
    params.require(%i[sharedTime hearing])
    params.permit(:sharedTime, hearing: {})
  end
end
