module Shotengai
  module Controller
    module Customer
      class Base < Shotengai::Controller::Base
        prepend_before_action :buyer_auth

        private
          def buyer_auth
            @buyer = params[:buyer_type].constantize.find(params[:buyer_id])
          end
      end
    end
  end
end
