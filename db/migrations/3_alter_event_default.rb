DB.alter_table(:events) do
  set_column_default :occurs_on, ''
end
