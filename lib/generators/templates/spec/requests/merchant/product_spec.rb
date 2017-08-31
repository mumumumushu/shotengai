require 'swagger_helper'
namespace = '<%= @namespace %>'
RSpec.describe "#{namespace}/products", type: :request, capture_examples: true, tags: ["#{namespace} API", "product"] do
  before do
    @merchant = create(:merchant)

    class Catalog < Shotengai::Catalog; end
    @clothes = Catalog.create!(name: '衣服')
    @jacket = Catalog.create!(name: '上衣', super_catalog: @clothes)

    @products = create_list(:product, 3)
    @product_1 = @products.first
    @product_1.update(catalog_list: ['衣服'])
    @series = create(:product_series, product: @product_1)
  end

  path "/#{namespace}/products" do

    get(summary: '商家 商品列表') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      parameter :page, in: :query, type: :string
      parameter :per_page, in: :query, type: :string
      parameter :catalog_list, in: :query, type: :array

      let(:page) { 1 }
      let(:per_page) { 2 }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it { expect(JSON.parse(response.body)['products'].count).to eq(2) }
      end

      response(200, description: 'filter by catalog') do

        let(:catalog_list) { @product_1.catalog_list }
        it { expect(JSON.parse(response.body)['products'].count).to eq(1) }
      end
    end

    post(summary: '管理员新建商品') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      parameter :product, in: :body, schema: {
        type: :object, properties: {
          product: {
            type: :object, properties: {
              title: { type: :string },
              default_series_id: { type: :integer },
              need_express: { type: :boolean },
              need_time_attr: { type: :boolean },
              cover_image: { type: :string },
              banners: { type: :array },
              detail: { 
                type: :object, 
                properties: {
                  product_detail: { type: :string },
                  notice: { type: :string },
                }
              },
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
                  meta2: { type: :ineteger },
                },
              },
              catalog_list: { type: :array }
            }
          }
        }
      }

      produces 'application/json'
      consumes 'application/json'
      response(201, description: 'successful') do
        product_attrs = FactoryGirl.attributes_for(:product)
        let(:product) {
          { 
            product:  product_attrs.merge( 
                default_series_id: @series.id,
                catalog_list: ['衣服', '上衣'],
              ) 
          }
        }
        it 'check attrs' do
         body = JSON.parse(response.body)
          the_same_values = ['spec', 'banners', 'detail', 'meta', 'title', 'need_express', 'need_time_attr'] # and so on
          expect(product_attrs.values_at the_same_values).to eq(body.values_at the_same_values)
          expect(body['default_series']['id']).to eq(@series.id), 'correct default_series'
          expect(body['catalog_list']).to eq(['衣服', '上衣']),  'add catalog list successful'
        end
      end
    end
  end

  path "/#{namespace}/products/{id}" do
    parameter 'id', in: :path, type: :string

    let(:id) { @product_1.id }

    get(summary: '商户 商品详情') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it {
           expect(JSON.parse(response.body)['series'].count).to eq(@product_1.series.count), "correct product's series"
        }
      end
    end
    patch(summary: 'update product') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      produces 'application/json'
      consumes 'application/json'

      parameter :product, in: :body, schema: {
        type: :object, properties: {
          product: {
            type: :object, properties: {
              title: { type: :string },
              default_series_id: { type: :integer },
              need_express: { type: :boolean },
              need_time_attr: { type: :boolean },
              cover_image: { type: :string },
              banners: { type: :array },
              detail: { 
                type: :object, 
                properties: {
                  product_detail: { type: :string },
                  notice: { type: :string },
                }
              },
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
                  meta2: { type: :ineteger },
                },
              },
              catalog_list: { type: :array }
            }
          }
        }
      }

      response(200, description: 'successful') do
        let(:product) { { product: FactoryGirl.attributes_for(:product) } }
      end
    end

    delete(summary: 'delete product') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      produces 'application/json'
      consumes 'application/json'
      response(204, description: 'successful') do
      end
    end
  end

  path "/#{namespace}/products/{id}/put_on_shelf" do
    parameter 'id', in: :path, type: :string

    let(:id) { @product_1.id }

    post(summary: '商户 上架商品') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }

      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        # it { p response.body }
      end
    end
  end

  path "/#{namespace}/products/{id}/sold_out" do
    parameter 'id', in: :path, type: :string

    let(:id) { @product_1.id }

    post(summary: '商户 下架商品') do
      parameter :manager_type, in: :query, type: :string
      parameter :manager_id, in: :query, type: :integer
      let(:manager_id) { @merchant.id }
      let(:manager_type) { @merchant.class.name }
      
      before { @product_1.update!(status: 'on_sale') }
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        # it { p response.body }
      end
    end
  end
end
