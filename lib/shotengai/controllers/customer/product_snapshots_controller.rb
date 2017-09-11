module Shotengai
  module Controller
    module Customer
      class ProductSnapshotsController < Shotengai::Controller::Base
        self.resources = ProductSnapshot
        self.template_dir = 'shotengai/customer/snapshots/'
        
        before_action :buyer_auth
        before_action :edit_only_unpaid, except: [:index, :show, :create]
        default_query do |resource, params|
          # /orders/:order_id/snapshots
          # /series/:series_id/snapshots
          resource.where(
              params[:order_id] && { shotengai_order_id: params[:order_id] }
            ).where(
              params[:series_id] && { shotengai_series_id: params[:series_id] }
            )
        end

        index_query do |resource, params|
          params[:in_cart] ? resource.in_cart : resource.in_order
        end

        # 不指定 order 时，默认创建在 cart 中
        # TODO: WARNING: snapshots
        def create
          order_or_cart = Shotengai::Order.find_by_id(params[:order_id]) || @buyer.order_cart
          @resource = order_or_cart.product_snapshots.create!(resource_params)
          respond_with @resource, template: "#{@@template_dir}/show", status: 201
        end

        private
          def buyer_auth
            @buyer = params[:buyer_type].constantize.find(params[:buyer_id])
          end

          def resource_params
            params.require(resource_key).permit(
              :count, :shotengai_series_id
            )
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.order.unpaid?
          end
      end
    end
  end
end
