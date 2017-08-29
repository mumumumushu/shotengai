json.extract! cart, :id
json.snapshots cart.snapshots, partial: 'shotengai/share/snapshot_simple', as: :snapshot