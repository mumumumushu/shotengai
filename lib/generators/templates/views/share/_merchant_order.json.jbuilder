json.extract! order, :id, :seq, :address, :amount,
  :product_amount, :product_original_amount, 
  :total_price, :total_original_price, 
  :pay_time, :delivery_time, :receipt_time, 
  :delivery_way, :delivery_cost, 
  :manager_remark, :mark, :customer_remark, 
  :status, :status_zh, :meta, :created_at
json.snapshots order.snapshots, partial: 'shotengai/share/snapshot_simple', as: :snapshot
