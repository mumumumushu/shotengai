require 'swagger_helper'
namespace = '<%= @customer_class_name.underscore %>'
RSpec.describe "#{namespace}/products/:product_id/product_series", type: :request, capture_examples: true, tags: ["#{namespace} API", "product_series"] do
  before do
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
  end

  path "/#{namespace}/products/{product_id}/product_series" do
    parameter :product_id, in: :path, type: :string
    let(:product_id) { @product_1.id }

    get(summary: '用户 某商品的 商品系列 列表') do
      
      parameter :page, in: :query, type: :string
      parameter :per_page, in: :query, type: :string      

      let(:page) { 1 }
      let(:per_page) { 100 }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { 
          expect(JSON.parse(response.body)['product_series'].count).to eq(@product_1.series.count) 
        }
      end
    end
  end

  path "/#{namespace}/product_series/{id}" do
    parameter :id, in: :path, type: :string

    let(:id) { @series_1.id }

    get(summary: '用户 商品系列的详情') do
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        # it { p response.body }
      end
    end
  end
end