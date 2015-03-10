DB.create_table(:messages) do
  primary_key :id
  String :author, null: false, default: ''
  String :subject, null: false, default: ''
  String :contents, null: false, default: ''
  Integer :event_id
  DateTime :received_at, null: false
  Boolean :is_event, null: false, default: false
end

