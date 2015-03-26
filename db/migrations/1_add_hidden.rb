DB.alter_table(:messages) do
  add_column :hidden, :boolean, null: false, default: false
  add_column :hide_reason, :string
end

