DB.alter_table(:messages) do
  add_column :event_date, :string

  add_index :event_date

  # Never used this, so removing
  drop_column :event_id
end
