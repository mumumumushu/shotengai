module Shotengai
  module Controller
    module Customer
      class CartsController < Shotengai::Controller::Customer::Base
        self.base_resources = Cart
        self.template_dir = 'shotengai/customer/cart'
        
        before_action :set_resource
        # NOTE: before_action would not keep the super methods' "only" condition

        remove_actions :index, :create, :destroy
        
        private
          def set_resource
            @resource = @buyer.order_cart
          end

          def resource_params
            params.require(resource_key).permit(
              :address, :customer_remark, 
              incr_snapshot_ids: [], gone_snapshot_ids: []
            )
          end

          def snapshot_params
            remark_value = params.fetch(:snapshot).fetch(:remark_input, nil)&.permit!
            params.require(:snapshot).permit(
              :shotengai_series_id, :count
            ).merge(remark_value: remark_value)
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.unpaid?
          end

      end
    end
  end
end
