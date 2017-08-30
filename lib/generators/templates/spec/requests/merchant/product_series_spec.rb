require 'swagger_helper'
namespace = '<%= @merchant_class_name.underscore %>'
RSpec.describe "#{namespace}/products/:product_id/product_series", type: :request, capture_examples: true, tags: ["#{namespace} API", "product_series"] do
  before do
    @clothes = Catalog.create!(name: '衣服')
    @jacket = Catalog.create!(name: '上衣', super_catalog: @clothes)

    @products = create_list(:product, 3)
    @product_1 = @products.first
    @product_1.update(catalog_list: ['衣服'])
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

    get(summary: '商家 某商品的 商品系列 列表') do
      
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

    post(summary: '管理员新建 商品系列') do
      parameter :product_series, in: :body, schema: {
        type: :object, properties: {
          product_series: {
            type: :object, properties: {
              original_price: { type: :decimal },
              price: { type: :decimal },
              stock: { type: :integer },
              spec: { 
                type: :object, 
                properties: {
                  color: { type: :array },
                  size: { type: :array },
                },
              },
              meta: { 
                type: :object, 
                properties: {
                  meta1: { type: :string },
                  meta2: { type: :integer },
                },
              },
            }
          }
        }
      }

      produces 'application/json'
      consumes 'application/json'
      response(201, description: 'successful') do
        product_series_attrs = FactoryGirl.attributes_for(:product_series)
        let(:product_series) {
          { product_series:  product_series_attrs }
        }
        it 'check attrs' do
          body = JSON.parse(response.body)
          expect(body['shotengai_product_id']).to eq(@product_1.id), 'methods default_query successful '
          expect(body['cover_image']).to eq(@product_1.cover_image), 'delegate info to product successful'
        end
      end
      
      response(400, description: 'failed, duplicate spec') do
        product_series_attrs = FactoryGirl.attributes_for(:product_series)
        let(:product_series) {
          { product_series:  product_series_attrs.merge(spec: @series_1.spec) }
        }
        it 'duplicate spec' do
          expect(response.status).to eq(400)
        #  p  body = JSON.parse(response.body)
        end
      end
    end
  end

  path "/#{namespace}/products/{product_id}/product_series/{id}" do
    parameter :id, in: :path, type: :string
    parameter :product_id, in: :path, type: :string

    let(:product_id) { @product_1.id }
    let(:id) { @series_1.id }

    get(summary: '商户 商品系列的详情') do
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        # it { p response.body }
      end
    end
    
    patch(summary: 'update product_series') do
      produces 'application/json'
      consumes 'application/json'
      
      parameter :product_series, in: :body, schema: {
        type: :object, properties: {
          product_series: {
            type: :object, properties: {
              original_price: { type: :decimal },
              price: { type: :decimal },
              stock: { type: :integer },
              spec: { 
                type: :object, 
                properties: {
                  color: { type: :array },
                  size: { type: :array },
                },
              },
              meta: { 
                type: :object, 
                properties: {
                  meta1: { type: :string },
                  meta2: { type: :integer },
                },
              },
            }
          }
        }
      }

      response(200, description: 'successful') do
        let(:product_series) { { product_series: FactoryGirl.attributes_for(:product_series) } }
      end
    end

    delete(summary: 'delete product_series') do
      produces 'application/json'
      consumes 'application/json'
      response(204, description: 'successful') do
      end
    end
  end
end
