require 'swagger_helper'
namespace = '<%= @customer_class_name.underscore %>'
RSpec.describe "#{namespace}/products", type: :request, capture_examples: true, tags: ["#{namespace} API", "product"] do
  before do
    class Catalog < Shotengai::Catalog; end
    @clothes = Catalog.create!(name: '衣服')
    @jacket = Catalog.create!(name: '上衣', super_catalog: @clothes)

    @products = create_list(:product, 3)
    @product_1 = @products.first
    @product_1.update(catalog_list: ['衣服'])
    @series = create(:product_series, product: @product_1)
  end

  path "/#{namespace}/products" do

    get(summary: '用户 商品列表') do
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
  end

  path "/#{namespace}/products/{id}" do
    parameter 'id', in: :path, type: :string

    let(:id) { @product_1.id }

    get(summary: '用户 商品详情') do
      produces 'application/json'
      consumes 'application/json'
      response(200, description: 'successful') do
        it {
           expect(JSON.parse(response.body)['series'].count).to eq(@product_1.series.count), "correct product's series"
        }
      end
    end
  end
end
