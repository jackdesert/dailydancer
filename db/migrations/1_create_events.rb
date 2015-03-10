DB.create_table(:events) do
  primary_key :id
  String :title, null: false, default: ''
  String :location, null: false, default: ''
  Date :date, null: false
end

