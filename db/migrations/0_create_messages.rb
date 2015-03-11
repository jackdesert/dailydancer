DB.create_table(:messages) do
  primary_key :id
  String :author, null: false, default: ''
  String :subject, null: false, default: ''
  String :plain, null: false, default: ''
  String :html, null: false, default: ''
  Integer :event_id
  DateTime :received_at, null: false
end

