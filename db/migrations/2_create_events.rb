DB.create_table(:events) do
  primary_key :id
  String   :day_of_week,  null: false, default: ''
  String   :time,         null: false, default: ''
  String   :name,         null: false, default: ''
  String   :url,          null: false, default: ''
  String   :hostess,      null: false, default: ''
  String   :location,     null: false, default: ''
  String   :location_url, null: false, default: ''
  String   :occurs_on,    null: false, default: 'all'
  DateTime :scraped_at,   null: false
end

