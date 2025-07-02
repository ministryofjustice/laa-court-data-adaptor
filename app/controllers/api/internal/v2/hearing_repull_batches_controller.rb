# frozen_string_literal: true

module Api
  module Internal
    module V2
      class HearingRepullBatchesController < ApplicationController
        def show
          batch = HearingRepullBatch.find(params[:id])
          render json: batch, status: :ok
        end

        def create
          batch = HearingRepullBatchCreator.call(params[:maat_ids])
          render json: batch, status: :created
        end
      end
    end
  end
end
