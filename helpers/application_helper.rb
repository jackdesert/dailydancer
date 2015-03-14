module ApplicationHelper
  def display_date(date)
    Chronic.parse(date).strftime('%A, %b %d')
  end
end
