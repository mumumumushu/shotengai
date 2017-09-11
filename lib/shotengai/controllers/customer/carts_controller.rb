module Shotengai
  module Controller
    module Customer
      class CartsController < Shotengai::Controller::Base
        self.resources = Cart
        self.template_dir = 'shotengai/customer/cart'
        
        before_action :buyer_auth
        before_action :set_resource
        # NOTE: before_action would not keep the super methods' "only" condition

        remove_actions :index, :create, :destroy
        
        default_query do |resource, params|  
        end
        
        index_query do |resource, params|
        end

        private
          def buyer_auth
            @buyer = params[:buyer_type].constantize.find(params[:buyer_id])
          end

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
            params.require(:snapshot).permit(
              :shotengai_series_id, :count
            )
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.unpaid?
          end

      end
    end
  end
end
