# require 'swagger_helper'
# namespace = '<%= @namespace %>'
# RSpec.describe "#{namespace}/product_snapshots", type: :request, capture_examples: true, tags: ["#{namespace} API", "product_snapshots"] do
#   before do
#     @user = create(:user)
#     @products = create_list(:product, 3)
#     @product_1 = @products.first

#     @series_1 = create(
#         :product_series, 
#           product: @product_1,
#           spec: {
#               "颜色" => "白色",
#               "大小" => "S",
#             }
#       )
#     @series_2 = create(
#         :product_series, {
#           product: @product_1,
#           spec: {
#               "颜色" => "黑色",
#               "大小" => "S",
#             }
#           }
#       )
#     @snapshot_1 = create(:product_snapshot, series: @series_1, count: 2)
#     @snapshot_2 = create(:product_snapshot, series: @series_1, count: 5)
#     @snapshot_other = create(:product_snapshot, series: @series_2, count: 5)

#     @order = create(:order)
#     @cart = @user.order_cart
#     @snapshot_1.update!(order: @order)
#     @snapshot_other.update!(order: @order)
#     @snapshot_2.update!(order_cart: @cart)
#   end
  
#   path "/#{namespace}/product_snapshots" do

#     get(summary: '用户 快照列表 三参数可仍以任意组合') do
#       parameter :buyer_type, in: :query, type: :string
#       parameter :buyer_id, in: :query, type: :integer
#       let(:buyer_id) { @user.id }
#       let(:buyer_type) { @user.class.name }

#       parameter :page, in: :query, type: :string
#       parameter :per_page, in: :query, type: :string      
#       parameter :series_id, in: :query, type: :integer
#       parameter :order_id, in: :query, type: :string
#       parameter :in_cart, in: :query, type: :boolean

#       let(:page) { 1 }
#       let(:per_page) { 100 }

#       produces 'application/json'
#       consumes 'application/json'
#       response(200, description: 'successful, query by product_series_id') do
#         let(:series_id) { @series_1.id }
        
#         it { 
#           p JSON.parse(response.body)
#           p '-------'
#           expect(JSON.parse(response.body)['product_snapshots'].count).to eq(@series_1.snapshots.in_order.count) 
#         }
#       end

#       response(200, description: 'successful, query by order_id') do
#         let(:order_id) { @order.id }
#         it { 
#           expect(JSON.parse(response.body)['product_snapshots'].count).to eq(@order.snapshots.count) 
#         }
#       end

#       response(200, description: 'successful, in_cart') do
#         let(:in_cart) { true }
#         it { 
#           expect(JSON.parse(response.body)['product_snapshots'].count).to eq(@cart.snapshots.count) 
#         }
#       end
#     end
    
#   end

#   path "/#{namespace}/product_snapshots/{id}" do
#     parameter :buyer_type, in: :query, type: :string
#     parameter :buyer_id, in: :query, type: :integer
#     let(:buyer_id) { @user.id }
#     let(:buyer_type) { @user.class.name }
    
#     let(:id) { @snapshot_1.id }

#     get(summary: '商户 商品快照的详情') do
#       produces 'application/json'
#       consumes 'application/json'
#       response(200, description: 'successful') do
#         it { expect(JSON(response.body)['total_price']).to eq('%.1f'% @snapshot_1.total_price) }
#       end
#     end
#   end

#   # path "/#{namespace}/product_series/{product_series_id}/product_snapshots" do
#   #   parameter :product_series_id, in: :path, type: :integer
#   #   parameter :order_id, in: :path, type: :string
#   #   parameter :in_cart, in: :path, type: :boolean
    
#   #   let(:product_series_id) { @series_1.id }

#   #   get(summary: '用户 快照列表 三参数可仍以任意组合') do
      
#   #     parameter :page, in: :query, type: :string
#   #     parameter :per_page, in: :query, type: :string      

#   #     let(:page) { 1 }
#   #     let(:per_page) { 100 }

#   #     produces 'application/json'
#   #     consumes 'application/json'
#   #     response(200, description: 'successful') do
#   #       it { 
#   #         expect(JSON.parse(response.body)['product_snapshots'].count).to eq(1) 
#   #       }
#   #     end
#   #   end

#     # post(summary: '用户 创建快照 ') do
      
#     #   parameter :product_snapshot, in: :body, schema: {
#     #     type: :object, properties: {
#     #       product_snapshot: {
#     #         type: :object, properties: {
#     #           count: { type: :integer },
#     #           buyer_id: { type: :integer },
#     #           buyer_type: { type: :string },
#     #         }
#     #       }
#     #     }
#     #   }
#     #   produces 'application/json'
#     #   consumes 'application/json'
#     #   response(200, description: 'successful') do
#     #     let(:product_snapshot) { 
#     #       { 
#     #         product_snapshot: { 
#     #           count: 10,
#     #           buyer_id: @user.id,
#     #           buyer_type: @user.class.name,
#     #         } 
#     #       } 
#     #     }
#     #     it { 
#     #       expect(JSON.parse(response.body)[':shotengai_series_id']).to eq(@series_1.id) 
#     #       expect(JSON.parse(response.body)['count']).to eq(10) 
#     #     }
#     #   end
#     # end

#   # end

#   # path "/#{namespace}/orders/{order_id}/product_snapshots" do
#   #   parameter :order_id, in: :path, type: :string
#   #   let(:order_id) { @order.id }

#   #   get(summary: '用户 (某订单中) 的快照列表') do
      
#   #     parameter :page, in: :query, type: :string
#   #     parameter :per_page, in: :query, type: :string      

#   #     let(:page) { 1 }
#   #     let(:per_page) { 100 }

#   #     produces 'application/json'
#   #     consumes 'application/json'
#   #     response(200, description: 'successful') do
#   #       it { 
#   #         expect(JSON.parse(response.body)['product_snapshots'].count).to eq(2) 
#   #       }
#   #     end
#   #   end
#   # end

#   # path "/#{namespace}/product_series/{product_series_id}/product_snapshots/{id}" do
#   #   parameter :product_series_id, in: :path, type: :string
#   #   parameter :id, in: :path, type: :string

#   #   let(:product_series_id) { @series_1.id }
#   #   let(:id) { @snapshot_1.id }

#   #   get(summary: '商户 商品快照的详情') do
#   #     produces 'application/json'
#   #     consumes 'application/json'
#   #     response(200, description: 'successful') do
#   #       it { expect(JSON(response.body)['product_status_zh']).to eq('未上架'), 'check product_status_zh' }
#   #     end
#   #   end
    
#   #   patch(summary: 'update product_snapshot 修改 revised_amount') do
#   #     produces 'application/json'
#   #     consumes 'application/json'
      
#   #     parameter :product_snapshot, in: :body, schema: {
#   #       type: :object, properties: {
#   #         product_snapshot: {
#   #           type: :object, properties: {
#   #             revised_amount: { type: :decimal }
#   #           }
#   #         }
#   #       }
#   #     }

#   #     response(200, description: 'successful') do
#   #       let(:product_snapshot) { 
#   #         { product_snapshot: { revised_amount: 233 } } 
#   #       }
#   #       it 'revised_amount as the total_price' do
#   #         expect(@snapshot_1.reload.revised_amount).to eq(233)
#   #       end
#   #     end

#   #     response(403, description: 'failed, can update a snapshot of unpaid order only ') do
#   #       let(:product_snapshot) { 
#   #         { product_snapshot: { revised_amount: 233 } } 
#   #       }
#   #       before { @snapshot_1.order.pay! }

#   #       it 'revised_amount as the total_price' do
#   #         expect(response.status).to eq(403)
#   #       end
#   #     end
#   #   end
#   # end
# end
