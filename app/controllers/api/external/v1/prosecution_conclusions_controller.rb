module Api
  module External
    module V1
      class ProsecutionConclusionsController < ApplicationController
        include ProsecutionConcludable
      end
    end
  end
end
