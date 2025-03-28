module Api
  module External
    module V2
      class ProsecutionConclusionsController < ApplicationController
        include ProsecutionConcludable
      end
    end
  end
end
