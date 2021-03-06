module Shotengai
  module Controller
    module Customer
      class OrdersController < Shotengai::Controller::Customer::Base
        self.base_resources = Order
        self.template_dir = 'shotengai/customer/orders/'
        
        before_action :edit_only_unpaid, only: [:update]
        
        remove_actions :destroy
        
        def default_query resources
          resources.where(buyer: @buyer)
        end

        def index_query resources
          resources.status_is(params[:status])
        end

        def create # Use :series_id & :count
          @resource = @buyer.buy_it_immediately(snapshot_params, resource_params)
          respond_with @resource, template: "#{@template_dir}/show", status: 201
        end

        def pay
          @resource.pay!
          respond_with @resource, template: "#{@template_dir}/show"
        end

        def destroy
          @resource.cancel!
          head 204
        end

        def confirm
          @resource.confirm!
          respond_with @resource, template: "#{@template_dir}/show"
        end

        private
          def resource_params
            params[resource_key] && params.require(resource_key).permit(
              :address, :customer_remark, 
              :delivery_way, :delivery_cost,
              incr_snapshot_ids: [], gone_snapshot_ids: []
            )
          end

          def snapshot_params
            remark_value = params.fetch(:snapshot).fetch(:remark_value, nil)&.permit!
            info_value = params.fetch(:snapshot).fetch(:info_value, nil)&.permit!
            params.fetch(:snapshot).permit(
              :shotengai_series_id, :count, 
            ).merge(remark_value: remark_value, info_value: info_value)
          end

          def edit_only_unpaid
            raise Shotengai::WebError.new('订单已支付，不可修改。', '-1', 403) unless @resource.unpaid?
          end

      end
    end
  end
end
