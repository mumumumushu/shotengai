module Shotengai
  module Controller
    module Merchant
      class ProductSeriesController < Shotengai::Controller::Merchant::Base
        self.base_resources = ProductSeries
        self.template_dir = 'shotengai/merchant/series/'

        skip_before_action :set_resource, only: [:batch_event, :recycle_bin]

        def default_query resources
          resources.alive.where(
            params[:product_id] && { shotengai_product_id: params[:product_id] }
          )
        end

        def recycle_bin
          page = params[:page] || 1
          per_page = params[:per_page] || 10
          @resources = default_resources.recycle_bin.paginate(page: page, per_page: per_page)
          respond_with @resources, template: "#{@template_dir}/index"
        end

        def destroy
          @resource.soft_delete!
          head 204
        end

        def batch_event # params[ids] params[:event]
          event = (@base_resources.where(nil).klass.aasm.events.map(&:name) & Array[params[:event].to_sym]).first
          raise ::Shotengai::WebError.new('Invaild event', '-1', 400) unless event
          # :relive only work for products in recycle_bin
          resources = event.eql?(:relive) ? default_resources.recycle_bin : default_resources
          ActiveRecord::Base.transaction do
            resources.where(id: params[:ids]).each(&"#{event}!".to_sym)
          end
          head 200
        end


        private
          def resource_params 
            spec_value = params.require(resource_key).fetch(:spec_value, nil)&.map(&:permit!)
            info_template = params.require(resource_key).fetch(:info_template, nil)&.map(&:permit!)
            detail_info_template = params.require(resource_key).fetch(:detail_info_template, nil)&.map(&:permit!)
            remark_value = params.require(resource_key).fetch(:remark_value, nil)&.map(&:permit!)
            meta = params.require(resource_key).fetch(:meta, nil)&.permit!
            # ????????!!!!!, spec_value: [:key, :val] 一样的输出值 却在test报错？？？
            # QUESTION: WARNING:  文档bug吧？？？？？
            params.require(resource_key).permit(
              :original_price, :price, :stock#, spec_value: [:key, :val]
            ).merge(
              { 
                spec_value: spec_value, info_template: info_template, remark_value: remark_value, 
                detail_info_template: detail_info_template,
                meta: meta 
              }
            )
          end

          def manager_auth
            @manager = params[:manager_type].constantize.find(params[:manager_id])
          end
      end
    end
  end
end
