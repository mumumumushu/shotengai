json.extract! order, :id, :seq, :status_zh, :address,
  :pay_time, :delivery_time, :receipt_time, 
  :delivery_way, :delivery_cost, 
  :merchant_remark, :mark, :customer_remark, 
  :status, :status_zh, :meta
json.snapshots, partial: 'shotengai/share/snapshot_simple', as: :series