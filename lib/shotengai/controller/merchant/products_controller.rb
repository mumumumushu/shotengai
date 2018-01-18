module Shotengai
  module Controller
    module Merchant
      class ProductsController < Shotengai::Controller::Merchant::Base
        self.base_resources = Product
        self.template_dir = 'shotengai/merchant/products/'

        skip_before_action :set_resource, only: [:batch_event, :relive, :recycle_bin]
        # add_actions :batch_event

        def default_query resources
          resources.alive.where(@manager && { manager: @manager })
        end

        def index_query resources
          resources.catalog_list_filter(
            ::Catalog.where(id: params[:catalog_ids])
          ).where(
            params[:status].blank?.! && { status: params[:status] }
          )
        end

        def put_on_shelf
          @resource.put_on_shelf!
          respond_with @resource, template: "#{@template_dir}/show", status: 200
        end

        def sold_out
          @resource.sold_out!
          respond_with @resource, template: "#{@template_dir}/show", status: 200
        end

        def relive
          @resource = default_resources.recycle_bin.find(params[:id])
          @resource.relive!
          respond_with @resource, template: "#{@template_dir}/show", status: 200
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

        def recycle_bin
          page = params[:page] || 1
          per_page = params[:per_page] || 10
          @resources = default_resources.recycle_bin.paginate(page: page, per_page: per_page)
          respond_with @resources, template: "#{@template_dir}/index"
        end

        private
          def resource_params 
            # QUESTION: need these ?
            # spec = params.require(resource_key).fetch(:spec, nil).try(:permit!)
            spec_template = params.require(resource_key).fetch(:spec_template, nil)&.map(&:permit!)
            remark_template = params.require(resource_key).fetch(:remark_template, nil)&.map(&:permit!)
            detail = params.require(resource_key).fetch(:detail, nil)&.permit!
            meta = params.require(resource_key).fetch(:meta, nil)&.permit!
            # NOTE: :catalog_list is a default catalog list for template example, maybe should move it to the template controller, but it need add controller template for every controller
            params.require(resource_key).permit(
              :title, :default_series_id, 
              :express_way, :need_time_attr, :cover_image, catalog_ids: [],
              banners: [], 
              # spec_template: [:key, val: []],
              # remark_template: [:key, :val],
            ).merge(
              { 
                spec_template: spec_template, remark_template: remark_template, 
                detail: detail, meta: meta 
              }
            )
          end
      end
    end
  end
end
