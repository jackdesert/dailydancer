CONFIG = YAML.load_file('config/smtp.yml')

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.gmail.com',
    :port => '587',
    :user_name  => CONFIG['user_name'],
    :password   => CONFIG['password'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

class Mailer
  RESTRICTED_EMAIL_ADDRESSES = ['list@sacredcircledance.org']

  class << self

    def confirm_listing(message)

      return if message.parsed_date.nil?

      to = message.author
      return if RESTRICTED_EMAIL_ADDRESSES.include?(to)

      subject = "Your Event Has Been Listed on Daily Dancer"

      date_object = message.parsed_date.to_date
      pretty_date = date_object.strftime('%b %d')
      pretty_date_with_weekday = date_object.strftime('%A, %b %d')
      author_first_name = message.author.split('<').first

      body  = erb :'mailers/confirm_listing', locals: { message: message }
      build_email(to, subject, body)
    end


    private

    def build_email(to_arg, subject_arg, body_arg)
      Mail.new do
        from     Mail.delivery_method.settings[:user_name]
        to       to_arg
        subject  subject_arg
        body     body_arg
      end
    end

  end

end
