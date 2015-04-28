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

  class << self

    def confirm_listing(message)
      to = message.author
      subject = "Your Event Has Been Listed on Daily Dancer"

      pretty_date = message.parsed_date.strftime('%b %d')
      pretty_date_with_weekday = message.parsed_date.strftime('%A, %b %d')
      author_first_name = message.author.split('<').first

      body  = haml :'mailers/confirm_listing', locals: { message: message }
      message = build_email(to, subject, body)
      message
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
