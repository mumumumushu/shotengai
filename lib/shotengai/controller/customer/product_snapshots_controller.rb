module Shotengai
  module Controller
    module Customer
      class ProductSnapshotsController < Shotengai::Controller::Customer::Base
        self.base_resources = ProductSnapshot
        self.template_dir = 'shotengai/customer/snapshots/'
        
        before_action :edit_only_unpaid, except: [:index, :show, :create]
        
        def default_query resources
          # /orders/:order_id/snapshots
          # /series/:series_id/snapshots
          order_id = request.path_info.include?('cart') ? @buyer.order_cart.id : params[:order_id]
          resources.where(
              order_id && { shotengai_order_id: order_id }
            ).count
          resources.where(
              order_id && { shotengai_order_id: order_id }
            ).where(
              params[:series_id] && { shotengai_series_id: params[:series_id] }
            )
        end

        # 不指定 order 时，默认创建在 cart 中
        # TODO: WARNING: snapshots
        def create
          @resource = default_resources.create!(resource_params)
          respond_with @resource, template: "#{@template_dir}/show", status: 201
        end

        private
          def resource_params
            remark_input = params.require(resource_key).fetch(:remark_input, nil)&.map(&:permit!)
            info_input = params.require(resource_key).fetch(:info_input, nil)&.map(&:permit!)
            params.require(resource_key).permit(
              :count, :shotengai_series_id
            ).merge({ remark_input: remark_input, info_input: info_input })
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.order.unpaid?
          end
      end
    end
  end
end
