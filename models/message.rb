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
    self.received_at = DateTime.now
    super
  end

end
