require 'swagger_helper'
namespace = '<%= @namespace %>'
RSpec.describe "#{namespace}/orders", type: :request, capture_examples: true, tags: ["#{namespace} API", "order"] do
  before do
    @user = create(:user)

    @products = create_list(:product, 3)
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

    @orders = create_list(:order, 3, buyer: @user)
    @order_1 = @orders.first
    @cart = @order_1.class.cart_class.create!(buyer: @user)

    @snapshot_1.update!(order: @order_1)
    @snapshot_other.update!(order: @order_1)
    @snapshot_2.update!(order_cart: @cart)
  end

  path "/#{namespace}/orders/cart" do
    
    get(summary: '用户 购物车') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      response(200, description: 'cart') do
        it { expect(JSON.parse(response.body)['snapshots'].count).to eq(1) }
      end
    end
  end

  path "/#{namespace}/orders/add_to_cart" do
    
    post(summary: '用户 添加快照至购物车( using series_id & count )') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }


      parameter :snapshot, in: :body, schema: {
        type: :object, properties: {
          snapshot: {
            type: :object, properties: {
              shotengai_series_id: { type: :integer },
              count: { type: :integer },
            }
          }
        }
      }

      response(201, description: 'Create snapshot and add it to the cart') do
        let(:snapshot) { 
          {
            snapshot: { 
              shotengai_series_id: @series_1.id,
              count: 10,
            }
          }
         }
        it { 
          expect(JSON.parse(response.body)['count']).to eq(10) 
          expect(@cart.snapshots.count).to eq(2) 
        }
      end
    end
  end


  path "/#{namespace}/orders" do

    get(summary: '用户 订单列表') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      parameter :page, in: :query, type: :string
      parameter :per_page, in: :query, type: :string
      parameter :status, in: :query, type: :string
      
      let(:page) { 1 }
      let(:per_page) { 100 }

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

    post(summary: '用户 创建订单(using incr_snapshot_ids') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      parameter :order, in: :body, schema: {
        type: :object, properties: {
          order: {
            type: :object, properties: {
              address: { type: :string },
              user_remark: { type: :text },
              incr_snapshot_ids: { type: :array },
              # gone_snapshot_ids: { type: :array },
            }
          }
        }
      }
      response(201, description: 'successful') do
        let(:order) {{
              order:  {
                address: 'This is an special address.',
                user_remark: 'user remark ...',
                incr_snapshot_ids: [ @snapshot_2.id ],
              }
           }}
        it {
          body = JSON.parse(response.body)
          expect(body['snapshots'].count).to eq(1)
          expect(body['snapshots'].first['id']).to eq(@snapshot_2.id)
          expect(@snapshot_2.reload.is_in_cart).to eq(false)
        }
      end

      response(400, description: 'failed, Cannot edit a snapshot which order was already paid.') do
  
        let(:order) {{
              order:  {
                incr_snapshot_ids: [ @snapshot_1.id ],
              }
           }}
        before { 
          @order_1.pay!
      }
        it {
          expect(response.status).to eq(400)
        }
      end
      
    end
  end


  path "/#{namespace}/orders/create_directly" do
    post(summary: 'create order') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      parameter :order_and_snapshot_params, in: :body, schema: {
        type: :object, properties: {
          order: {
            type: :object, properties: {
              address: { type: :string },
              user_remark: { type: :text },
            },
          snapshot: {
            type: :object, properties: {
              shotengai_series_id: { type: :integer },
              count: { type: :integer },
            }
          }
          }
        }
      }

      response(201, description: 'successful') do
        let(:order_and_snapshot_params) {
          {
            order:  {
              address: 'This is an special address.',
              user_remark: 'user remark ...'
            },
            snapshot: { 
              shotengai_series_id: @series_1.id,
              count: 10,
            }
          }
        }

        it {
          body = JSON.parse(response.body)
          expect(body['snapshots'].count).to eq(1)
          expect(body['snapshots'].first['shotengai_series_id']).to eq(@series_1.id)
        }
      end
    end
  end


  path "/#{namespace}/orders/{id}" do
    parameter :id, in: :path, type: :integer

    let(:id) { @order_1.id }

    get(summary: '用户 订单详情') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }
      
      response(200, description: 'successful') do
        it {
           expect(JSON.parse(response.body)['snapshots'].count).to eq(@order_1.snapshots.count)
        }
      end
    end

    patch(
      summary: 'update order
        【 incr_snapshot_ids 移入该order的snapshot_id 数组，
          gone_snapshot_ids 移入购物车的 snapshot_id 数组 】'
    ) do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      parameter :order, in: :body, schema: {
        type: :object, properties: {
          order: {
            type: :object, properties: {
              address: { type: :string },
              user_remark: { type: :text },
              incr_snapshot_ids: { type: :array },
              gone_snapshot_ids: { type: :array },
            }
          }
        }
      }

      response(200, description: 'successful') do
        let(:order) {{
              order:  {
                address: 'This is an special address.',
                user_remark: 'user remark ...',
                incr_snapshot_ids: [ @snapshot_2.id ],
                gone_snapshot_ids: [ @snapshot_1.id ],
              }
           }}
        it {
          expect(@order_1.reload.address).to eq('This is an special address.')
          # Move @snapshot_1 out of order to the cart
          expect(@snapshot_1.reload.is_in_cart).to eq(true)
          # Move @snapshot_2 into order
          expect(@snapshot_2.reload.is_in_cart).to eq(false)
        }
      end

      response(403, description: 'failed, Can edit a unpaid order only.') do
        let(:order) {{
              order:  {
                address: 'This is an special address.',
                user_remark: 'user remark ...'
              }
           }}
        before { @order_1.pay! }
        it {
          expect(response.status).to eq(403)
        }
      end
    end
  end

  path "/#{namespace}/orders/{id}/pay" do
    parameter :id, in: :path, type: :integer

    let(:id) { @order_1.id }

    post(summary: '用户 支付订单') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['pay_time']).not_to be_nil }
      end
    end
  end

  path "/#{namespace}/orders/{id}/cancel" do
    parameter :id, in: :path, type: :integer

    let(:id) { @order_1.id }

    post(summary: '用户 取消未支付订单') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['status']).to eq('canceled') }
      end

      response(400, description: 'failed , you can cancel a order which status is unpaid') do
        before { @order_1.pay! }
        it { expect(response.status).to eq(400) }
      end
    end
  end

  path "/#{namespace}/orders/{id}/get_it" do
    parameter :id, in: :path, type: :integer

    let(:id) { @order_1.id }

    post(summary: '用户 确认收货') do
      produces 'application/json'
      consumes 'application/json'
      parameter :buyer_type, in: :query, type: :string
      parameter :buyer_id, in: :query, type: :integer
      let(:buyer_id) { @user.id }
      let(:buyer_type) { @user.class.name }

      before { @order_1.update!(status: 'delivering') }
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['receipt_time']).not_to be_nil }
      end
    end
  end
end
