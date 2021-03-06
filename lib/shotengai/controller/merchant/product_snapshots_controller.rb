module Shotengai
  module Controller
    module Merchant
      class ProductSnapshotsController < Shotengai::Controller::Merchant::Base
        self.base_resources = ProductSnapshot
        self.template_dir = 'shotengai/merchant/snapshots/'
        
        remove_actions :create, :destroy
        before_action :edit_only_unpaid, only: :update

        def default_query resources
          resources.in_order  
        end

        def index_query resources
          resources.where(
              params[:order_id] && { shotengai_order_id: params[:order_id] }
            ).where(
              params[:product_series_id] && { shotengai_series_id: params[:product_series_id] }
            )
        end

        private
          def resource_params
            remark_value = params.require(resource_key).fetch(:remark_value, {}).permit!
            params.require(resource_key).permit(
              :revised_amount
            ).merge(remark_value: remark_value)
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改该快照。', '-1', 403) unless @resource.order.unpaid?
          end

          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end
      end
    end
  end
end
