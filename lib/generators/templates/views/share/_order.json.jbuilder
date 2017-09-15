json.extract! order, :id, :seq, :total_price, :total_original_price, 
  :status_zh, :address,
  :pay_time, :delivery_time, :receipt_time, 
  :delivery_way, :delivery_cost, :customer_remark, 
  :status, :status_zh, :meta, :created_at
json.snapshots order.snapshots, partial: 'shotengai/share/snapshot_simple', as: :snapshot