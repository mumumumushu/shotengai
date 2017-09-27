module Shotengai
  module Controller
    module Merchant
      class Base < Shotengai::Controller::Base
        prepend_before_action :manager_auth

        private
          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end
      end
    end
  end
end
