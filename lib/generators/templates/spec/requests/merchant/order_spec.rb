require 'swagger_helper'
namespace = '<%= @namespace %>'
RSpec.describe "#{namespace}/orders", type: :request, capture_examples: true, tags: ["#{namespace} API", "order"] do
  before do
    @merchant = create(:merchant)
    
    @products = create_list(:product, 3, manager: @merchant)
    @product_1 = @products.first
    @series_1 = create(
        :product_series, 
          product: @product_1,
          spec: {
              "颜色" => "白色",
              "大小" => "S",
            }
      )
    @series_2 = create(
        :product_series, {
          product: @product_1,
          spec: {
              "颜色" => "黑色",
              "大小" => "S",
            }
          }
      )
    @snapshot_1 = create(:product_snapshot, series: @series_1, count: 2)
    @snapshot_2 = create(:product_snapshot, series: @series_1, count: 5)
    @snapshot_other = create(:product_snapshot, series: @series_2, count: 5)

    @orders = create_list(:order, 3)
    @order_1 = @orders.first
    @cart = create(:user).order_cart

    @snapshot_1.update!(order: @order_1)
    @snapshot_other.update!(order: @order_1)
    @snapshot_2.update!(order_cart: @cart)
  end

  path "/#{namespace}/orders" do

    get(summary: '商家 订单列表') do
      # QUESTION: 商家需要 查看 未支付的订单？
      parameter :page, in: :query, type: :string
      parameter :per_page, in: :query, type: :string
      parameter :status, in: :query, type: :string
      
      let(:page) { 1 }
      let(:per_page) { 100 }

      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['orders'].count).to eq(3) }
      end

      response(200, description: 'filter by status') do
        before { @orders.last.pay! }
        let(:status) { 'paid' }
        it { expect(JSON.parse(response.body)['orders'].count).to eq(1) }
      end
    end

  end

  path "/#{namespace}/orders/{id}" do
    parameter 'id', in: :path, type: :string
    let(:id) { @order_1.id }

    parameter :manager_type, in: :query, type: :string
    parameter :manager_id, in: :query, type: :integer
    let(:manager_id) { @merchant.id }
    let(:manager_type) { @merchant.class.name }

    get(summary: '商户 订单详情') do
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it {
          #  expect(JSON.parse(response.body)['snapshots'].count).to eq(@order_1.snapshots.count)
        }
      end
    end

    patch(summary: 'update product') do
      produces 'application/json'
      consumes 'application/json'

      parameter :order, in: :body, schema: {
        type: :object, properties: {
          order: {
            type: :object, properties: {
              mark: { type: :string },
              merchant_remark: { type: :text },
            }
          }
        }
      }

      response(200, description: 'successful') do
        let(:order) {{
              order:  {
                mark: 'red mark',
                merchant_remark: 'merchant remark ...'
              }
           }}
        it {
          expect(@order_1.reload.mark).to eq('red mark')
        }
      end
    end
  end

  path "/#{namespace}/orders/{id}/send_out" do
    parameter 'id', in: :path, type: :string
    let(:id) { @order_1.id }

    parameter :manager_type, in: :query, type: :string
    parameter :manager_id, in: :query, type: :integer
    let(:manager_id) { @merchant.id }
    let(:manager_type) { @merchant.class.name }
    
    post(summary: '商户 确认订单开始配送') do
      before { @order_1.pay! }
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['delivery_time']).not_to be_nil }
      end
    end
    
    post(summary: '商户 确认订单开始配送') do
      produces 'application/json'
      consumes 'application/json'
      response(400, description: 'failed wrong initial status') do
        it { expect(response.status).to eq(400) }
      end
    end
  end
end
