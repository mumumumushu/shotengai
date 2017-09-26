module Shotengai
  module Controller
    module Merchant
      class ProductSeriesController < Shotengai::Controller::Merchant::Base
        self.base_resources = ProductSeries
        self.template_dir = 'shotengai/merchant/series/'

        skip_before_action :set_resource, only: :batch_event

        # add_actions :batch_event

        def default_query resources
          resources.alive.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end

        def destroy
          @resource.soft_delete!
          head 204
        end

        def batch_event # params[ids] params[:event]
          event = (@base_resources.where(nil).klass.aasm.events.map(&:name) & Array[params[:event].to_sym]).first
          raise ::Shotengai::WebError.new('Invaild event', '-1', 400) unless event
          ActiveRecord::Base.transaction do
            default_resources.where(id: params[:ids]).each(&"#{event}!".to_sym)
          end
          head 200
        end

        private
          def resource_params 
            spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
            meta = params.require(resource_key).fetch(:meta, nil).try(:permit!)
            params.require(resource_key).permit(
              :original_price, :price, :stock
            ).merge(
              { spec: spec, meta: meta }
            )
          end

          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end
      end
    end
  end
end
