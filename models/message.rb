class Message < Sequel::Model

  plugin :validation_helpers


  def validate
    super
    # Note there is no validation on received_at because it is set
    # in before_create (which happens after validation)
    #
    # Note there is no validation on html or plain, since one of them may be blank
    # TODO require at least one of them to be present
    validates_presence :author
    validates_presence :subject
    validates_presence :plain
  end

  def before_create
    self.received_at ||= DateTime.now
    super
  end

  def parsed_date
    @parsed_date ||= DateParser.new(plain).parse
  end

  def self.by_date(num_days)
    return {} if num_days == 0
    output = {}
    messages = Message.all.sort_by(&:parsed_date)
    range_of_dates(num_days).each do |date|
      output[date.to_s] = []
      while date == messages.first.try(:parsed_date)
        output[date.to_s] << messages.pop
      end
    end
  end

  def self.range_of_dates(num_days)
    today = Util.current_date_in_portland
    dates = (today..today + num_days - 1).to_a
    dates.map(&:to_s)
  end

end
