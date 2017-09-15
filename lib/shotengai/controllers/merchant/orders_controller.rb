module Shotengai
  module Controller
    module Merchant
      class OrdersController < Shotengai::Controller::Base
        self.base_resources = ::Order
        self.template_dir = 'shotengai/merchant/orders/'
       
        remove_actions :create, :destroy
        
        def index_query resources
          resources.status_is(params[:status])
        end

        def send_out
          @resource.send_out!
          respond_with @resource, template: "#{@template_dir}/show"
        end

        private
          def resource_params
            params.require(resource_key).permit(
              :merchant_remark, :mark
            )
          end
      end
    end
  end
end
