module Shotengai
  module Controller
    module Merchant
      class ProductSnapshotsController < Shotengai::Controller::Base
        self.resources = ProductSnapshot
        self.template_dir = 'shotengai/merchant/snapshots/'
        
        remove_actions :create, :destroy

        default_query do |resource, params|
          resource.in_order  
        end

        index_query do |resource, params|
          resource.where(
              params[:order_id] && { shotengai_order_id: params[:order_id] }
            ).where(
              params[:product_series_id] && { shotengai_series_id: params[:product_series_id] }
            )
        end

        def update
          raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.order.unpaid?
          super
        end

        private
          def resource_params
            params.require(resource_key).permit(
              :revised_amount
            )
          end
      end
    end
  end
end
