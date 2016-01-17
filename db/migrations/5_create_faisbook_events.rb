DB.create_table(:faisbook_events) do
  primary_key :id
  Integer  :faisbook_id,  null: false

  # These fields allowed to be NULL:
  String   :name
  String   :description
  String   :location
  String   :address

  String   :start_time
  String   :end_time

  # Format is '2016-02-04'
  String   :date


  DateTime :created_at,   null: false
  DateTime :updated_at,   null: false
end

