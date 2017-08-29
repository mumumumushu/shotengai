module Shotengai
  module Controller
    module Customer
      class ProductSnapshotsController < Shotengai::Controller::Base
        self.resources = ProductSnapshot
        self.template_dir = 'shotengai/merchant/snapshots/'
        
        before_action :edit_only_unpaid, only: [:update, :destroy]

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

        def create
          buyer_type, buyer_id = resource_params.values_at(:buy_type, :buyer_id)
          @buyer = buyer_type.constantize.find(buyer_id) if buyer_type && buyer_id
          @resource = default_resources.create!(
            resource_params.merge(buyer: buyer)
          )
          respond_with @resource, template: "#{@@template_dir}/show", status: 201
        end

        private
          def resource_params
            params.require(resource_key).permit(
              :count, :shotengai_series_id, :buyer_id, :buy_type
            )
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.order.unpaid?
          end
      end
    end
  end
end
