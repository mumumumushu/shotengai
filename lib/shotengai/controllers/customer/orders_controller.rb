module Shotengai
  module Controller
    module Customer
      class OrdersController < Shotengai::Controller::Base
        self.resources = Order
        self.template_dir = 'shotengai/customer/orders/'
        
        before_action :buyer_auth
        before_action :edit_only_unpaid, only: [:update]
        # before_action would not keep the super methods' "only" condition
        skip_before_action :set_resource, only: [:cart, :add_to_cart, :create_directly]

        remove_actions :destroy
        
        default_query do |resource, params|  
        end
        
        index_query do |resource, params|
          resource.status_is(params[:status])
        end
        
        def cart
          @resource = @buyer.order_cart  
          respond_with @resource, template: "shotengai/customer/cart/show"
        end

        def add_to_cart
          snapshot = @buyer.order_cart.product_snapshots.create!(snapshot_params)
          respond_with @resource = snapshot, template: 'shotengai/customer/snapshots/show', status: 201
        end

        def create_directly # using :series_id & :count
          ActiveRecord::Base.transaction do
            @resource = @buyer.orders.create!(resource_params)
            Shotengai::Series.find(snapshot_params[:shotengai_series_id]).snapshots.create!(
                count: snapshot_params[:count],
                shotengai_order: @resource
              )
          end
          respond_with @resource, template: "#{@@template_dir}/show", status: 201
        end

        def pay
          @resource.pay!
          respond_with @resource, template: "#{@@template_dir}/show"
        end

        def cancel
          @resource.cancel!
          respond_with @resource, template: "#{@@template_dir}/show"
        end

        def get_it
          @resource.get_it
          respond_with @resource, template: "#{@@template_dir}/show"
        end

        private
          def buyer_auth
            @buyer = params[:buyer_type].constantize.find(params[:buyer_id])
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
