module Shotengai
  module Controller
    module Customer
      class OrdersController < Shotengai::Controller::Base
        self.resources = Order
        self.template_dir = 'shotengai/customer/orders/'
        
        before_action :buyer_auth
        before_action :edit_only_unpaid, only: [:update]

        remove_actions :destroy
        
        default_query  do |resource, params, request|  
        end
        
        index_query  do |resource, params, request|
          request.params
          resource.status_is(params[:status])
        end

        def create # Use :series_id & :count
          @resource = @buyer.buy_it_immediately(snapshots_params, resource_params)
          respond_with @resource, template: "#{@@template_dir}/show", status: 201
        end

        def pay
          @resource.pay!
          respond_with @resource, template: "#{@@template_dir}/show"
        end

        def destroy
          @resource.cancel!
          head 204
        end

        def confirm
          @resource.confirm!
          respond_with @resource, template: "#{@@template_dir}/show"
        end

        private
          def buyer_auth
            @buyer = params[:buyer_type].constantize.find(params[:buyer_id])
          end

          def resource_params
            params[resource_key] && params.require(resource_key).permit(
              :address, :customer_remark, 
              incr_snapshot_ids: [], gone_snapshot_ids: []
            )
          end

          def snapshots_params
            params[:snapshots] && params.require(:snapshots).permit(
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
