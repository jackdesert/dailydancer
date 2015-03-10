class Event < Sequel::Model

  one_to_many :messages

end
