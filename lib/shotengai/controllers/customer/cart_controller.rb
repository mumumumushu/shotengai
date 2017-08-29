module Shotengai
  module Controller
    module Customer
      class OrdersController < Shotengai::Controller::Base
        self.resources = Cart
        self.template_dir = 'shotengai/customer/orders/'
        
        remove_actions

        index_query do |resource, params|
          resource.status_is(params[:status])
        end

        def add_to_cart
          buyer_type, buyer_id = add_to_cart_params.values_at(:buyer_type, :buyer_id)
          buyer = buyer_type.constantize.find(buyer_id)
          @snapshot = buyer.order_cart.snapshots.create!(add_to_cart_params)
          head 201
        end

        def create_by_snapshot
          
        end

        def create_directly
          
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
          def resource_params
            params.require(resource_key).permit(
              :address, :customer_remark, snapshot_ids: []
            )
          end

          def add_to_cart_params
            params.require(:snapshot).permit(
              :series_id, :count, :buyer_type, :buyer_id
            )
          end
      end
    end
  end
end
