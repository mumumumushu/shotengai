module Shotengai
  module Controller
    module Merchant
      class OrdersController < Shotengai::Controller::Merchant::Base
        self.base_resources = ::Order
        self.template_dir = 'shotengai/merchant/orders/'
        
        remove_actions :create, :destroy
        
        def default_query resources
          @manager.orders
        end

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
              :mark, manager_remark: [],
            )
          end
          
          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end
      end
    end
  end
end
