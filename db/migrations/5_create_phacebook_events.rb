DB.create_table(:faisbook_events) do
  primary_key :id
  Integer  :faisbook_id,  null: false, default: ''

  String   :name,         null: false, default: ''
  String   :description,  null: false, default: ''
  String   :location,     null: false, default: ''
  String   :address,      null: false, default: ''

  String   :start_time,   null: false, default: ''
  String   :end_time,     null: false, default: ''

  # Format is '2016-02-04'
  String   :date,         null: false, default: ''

  DateTime :created_at,   null: false
  DateTime :updated_at,   null: false
end

