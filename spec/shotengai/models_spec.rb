require 'spec_helper'

mysql_setting_file = '../../mysql.yml'
mysql_setting = File.exist?(mysql_setting_file) ? YAML.load(File.read(mysql_setting_file)) : { username: 'root', password: nil }

Dir['db/migrate/*'].map{ |x| File.basename(x)}.each { |f| require_relative "../../db/migrate/#{f}"}

ActiveRecord::Base.establish_connection(
  adapter: 'mysql2',
  username: mysql_setting[:username],
  password: mysql_setting[:password] || '',
)
c = ActiveRecord::Base.connection
c.exec_update('drop database if exists shotengai_test;')
c.exec_update('create database shotengai_test')
c.exec_update('use shotengai_test')

RSpec.describe 'Shotengai Models' do
  before do
    ActiveRecord::Migration[5.1].subclasses.each do |migrate|
      migrate.migrate(:up)
    end
  end

  describe 'Product & Order' do
    before do
      class TestGood < Shotengai::Product; end
      class OtherGood < Shotengai::Product; end

      class TestOrder < Shotengai::Order
        can_buy 'TestGood'
      end

      class TestBuyer < ActiveRecord::Base
        include Shotengai::Buyer
        can_shopping_with 'TestOrder'
        
        ActiveRecord::Base.connection.create_table(:test_buyers) unless ActiveRecord::Base.connection.table_exists?(:test_buyers)
      end

      @good = create(:test_good)
      @series = create(:test_series, test_good: @good)
      @snapshot = create(:test_snapshot, series: @series)

      @other_good = create(:other_good)
      @other_series = create(:other_series, other_good: @other_good)
      @other_snapshot = create(:other_snapshot, series: @other_series)
      @buyer = TestBuyer.create
    end

    describe 'About Product' do
      it 'validate' do
        expect(@good.spec.class).to eq(Hash)
        expect(@good.banners.class).to eq(Array)
        # Do not check_spec if spec is nil
        expect(@good.update!(spec: nil)).to eq(true)
      end
      it 'Associations' do
        # has many Series
        expect(@good.series.to_a).to eq([ @series ])
        # has many Snapshot through Series
        expect(@good.snapshots.to_a).to eq([ @snapshot ])
      end
    end

    describe 'About Series' do
      it 'validate' do
        expect(@series.spec.class).to eq(Hash)
        # 非法关键字
        expect{
          @series.update!(spec: {"颜色" => "红色", "大小" => 1111 })
        }.to raise_error(ActiveRecord::RecordInvalid)
        # 关键字缺失
        expect{ 
          @series.update!(spec: {"颜色" => "红色"})
        }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'Associations' do
        # has_many Snapshot
        expect(@series.snapshots.to_a).to eq([ @snapshot ])
        # belongs to Product
        expect(@series.product).to eq(@good)
        expect(@series.test_good).to eq(@good)
      end

      it 'methods' do
        expect(@good.default_series).to eq(@series)
      end
    end

    describe 'About Snapshot' do
      it 'validate' do
        expect(@snapshot.spec.class).to eq(Hash)
        expect(@snapshot.meta.class).to eq(Hash)
      end

      it 'Associations' do
        # belongs to Series
        expect(@snapshot.series).to eq(@series)
        expect(@snapshot.test_good_series).to eq(@series)
      end

      it 'pay' do
        @unpaid_snapshot = TestGoodSnapshot.create(
          series: @series,
          count: 2
        )
        # 支付前 属性 delegate to Series
        expect(@unpaid_snapshot.price).to eq(@series.price)
        expect(@unpaid_snapshot.attributes['price']).to eq(nil)
        # 支付后 copy_info
        @unpaid_snapshot.copy_info
        copy_attrs = [:original_price, :price, :spec, :banners, :cover_image, :detail]
        expect(@unpaid_snapshot.attributes.slice(copy_attrs)).to eq(@series.attributes.slice(copy_attrs))
        expect(@unpaid_snapshot.meta).to eq(@good.meta.merge(@series.meta))
      end
    end

    describe 'About Cart' do
      it 'methods' do
        TestOrder::Cart.destroy_all
        # 不存在时创建
        expect(@buyer.test_order_cart.class).to eq(TestOrder::Cart)
        # 存在时加载
        expect(@buyer.test_order_cart.class).to eq(TestOrder::Cart)
        
        # Add Snapshot to Cart
        @buyer.add_to_test_order_cart(@snapshot)
        expect(@snapshot.test_order_cart).to eq(@buyer.test_order_cart)
      end
      
    end

    describe 'About Order' do
      it 'Associations' do
        @buyer.test_order_cart # create a TestOrder::Cart instance object
        # Should not include the TestOrder::Cart instance object
        expect(@buyer.test_orders.empty?).to be(true)
      end
      describe do
        before do
          @order = @buyer.test_orders.create
          @snapshot_1 = @order.test_good_snapshots.create(count: 2, series: @series)
          @snapshot_2 = @order.test_good_snapshots.create(count: 10, series: @series)
        end

        it 'Methods' do
          # total_price
          expect(@order.total_price).to eq(@snapshot_1.total_price + @snapshot_2.total_price)
          expect(@order.total_original_price).to eq(@snapshot_1.total_original_price + @snapshot_2.total_original_price)
        end

        it 'About state machine' do
          expect(@snapshot_1.reload.attributes.values.include?(nil)).to eq(true)
          @order.pay!
          expect(@order.reload.pay_time).not_to be_nil
          # copy snapshot info from series
          expect(@snapshot_1.reload.attributes.values.expect(:revised_amount).include?(nil)).to eq(false)
          @order.send_out!
          # set delivery_time
          expect(@order.reload.delivery_time).not_to be_nil
          @order.get_it!
          # set receipt_time
          expect(@order.reload.receipt_time).not_to be_nil
        end
      end
    end
  end

  describe 'Catalog' do
    before do

      class ClothingCatalog < Shotengai::Catalog; end
      class OtherCatalog < Shotengai::Catalog; end

      @klass = ClothingCatalog
      @clothing = @klass.create(name: '衣服')
      @trousers = @klass.create(name: '下装', super_catalog: @clothing)
      @pants = @klass.create(name: '短裤', super_catalog: @trousers)

      @tops = @klass.create(name: '上装', super_catalog: @clothing)
      @shirts = @klass.create(name: '衬衫', super_catalog: @tops)
      @jacket = @klass.create(name: '夹克', super_catalog: @tops)
      @sweaters = @klass.create(name: '毛衣', super_catalog: @tops)
      @polo_shirts = @klass.create(name: 'Polo衫', super_catalog: @shirts)
      @other_clothes_catalog = @klass.create(name: '其他分类')

      @other_catalog = OtherCatalog.create(name: '其他分类')
    end

    describe 'Methods' do
      it 'instance_methods' do
        # .ancestors
        expect(@jacket.ancestors).to eq( [@clothing, @tops, @jacket] )
        # .chain_chain
        expect(@polo_shirts.name_chain).to eq( ["衣服", "上装", "衬衫", "Polo衫"] )
        # .nest_level
        expect(@polo_shirts.nest_level).to eq(4)
        # .brothers
        expect(@shirts.brothers.sort).to eq( [@jacket, @sweaters, @shirts].sort)
      end
      it 'Class Methods' do
        # self.top_catalogs
        expect(@klass.top_catalogs.sort).to eq([@clothing, @other_clothes_catalog].sort)
        # self.validate_chain
        expect(@klass.validate_name_chain(["衣服", "上装", "衬衫", "Polo衫"])).to eq(["衣服", "上装", "衬衫", "Polo衫"])
        expect { 
          @klass.validate_name_chain( ["衣服", "上装", "error 衬衫", "Polo衫"])
        }.to raise_error(Shotengai::WebError)      
      end
    end

    describe 'Catalog System With Product' do
      before do
        class TestGood < Shotengai::Product
          join_catalog_system 'ClothingCatalog', as: :sort
          join_catalog_system 'OtherCatalog'
        end  
      end
      
      it 'Edit Catalog' do
        @good = create(:test_good)
        # create clothes catalog_list
        list = ["衣服", "上装", "衬衫"]
        @good.sort_list = list
        @good.save!
        expect(@good.reload.sort_list).to eq(list)
        expect {
          @good.sort_list = ["衣服", "error 上装", "衬衫"]
        }.to raise_error(Shotengai::WebError)
        # 完整替换分类
        @good.update!(
          sort_list: ["衣服", "上装", "衬衫", "Polo衫"],
          other_catalog_list: [ @other_catalog.name ]
        )
        expect(@good.reload.sort_list).to eq(["衣服", "上装", "衬衫", "Polo衫"])
        expect(@good.reload.other_catalog_list).to eq( [ @other_catalog.name ] )
      end

      before do
        @jacket_good = create(:test_good, 
          sort_list: @jacket.name_chain
        )
        @polo_shirts_good = create(:test_good, 
          sort_list: @polo_shirts.name_chain
        )
        @pants_good = create(:test_good, 
          sort_list: @pants.name_chain,
          other_catalog_list: @other_catalog.name_chain
        )
      end

      it 'Query by Catalog' do
        expect(
          TestGood.tagged_with('衣服', on: :sort).sort
        ).to eq([ @jacket_good, @polo_shirts_good, @pants_good ].sort)
        expect(
          TestGood.tagged_with('上装', on: :sort).sort
        ).to eq([ @jacket_good, @polo_shirts_good ].sort)
        # other_catalog_list 
        expect(
          TestGood.tagged_with(@other_catalog.name, on: :other_catalogs).sort
        ).to eq([ @pants_good ].sort)
      end
    end
  end

  after do
    ActiveRecord::Migration[5.1].subclasses.each do |migrate|
      migrate.migrate(:down)
    end
  end
end

# ActiveRecord::Migration[5.1].subclasses.each do |migrate|
#   migrate.migrate(:down)
# end