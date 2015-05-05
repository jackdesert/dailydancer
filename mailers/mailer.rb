CONFIG = YAML.load_file('config/smtp.yml')

Mail.defaults do
  delivery_method :smtp, {
    :address => 'smtp.zoho.com',
    :port => '587',
    :user_name  => CONFIG['user_name'],
    :password   => CONFIG['password'],
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end

module Mail
  class NullMessage < Message
    def deliver
      # Do nothing
    end
  end
end


class Mailer
  SUPPORT_EMAIL = 'support@pdxdailydancer.com'

  class << self

    def null_message
      Mail::NullMessage.new
    end

    def confirm_listing(message)

      return null_message if message.parsed_date.nil?

      original_to = message.author_multiple_source
      to = ['Jack <jackdesert556@gmail.com>', SUPPORT_EMAIL]

      # One more check to make sure no mail is sent directly to the list
      return null_message if          to.include?(Message::LIST_EMAIL_ADDRESS)
      return null_message if original_to.include?(Message::LIST_EMAIL_ADDRESS)
      return null_message if original_to == Message::UNKNOWN_AUTHOR
      return null_message if          to == Message::UNKNOWN_AUTHOR

      subject = "Your Event Has Been Listed on Daily Dancer"

      date_object = message.parsed_date.to_date

      # Using strftime on each piece individually in order to get
      # day of month with no leading zero and no zero space
      month = date_object.strftime('%B')
      day_of_week = date_object.strftime('%A')
      day_of_month = date_object.strftime('%e').strip

      pretty_date = "#{month} #{day_of_month}"
      pretty_date_with_weekday = "#{day_of_week} #{pretty_date}"

      author_first_name = message.author_multiple_source.split('<').first.strip

      # Create a binding that will be available to the ERB template
      b = binding
      b.local_variable_set(:pretty_date, pretty_date)
      b.local_variable_set(:pretty_date_with_weekday, pretty_date_with_weekday)
      b.local_variable_set(:author_first_name, author_first_name)
      b.local_variable_set(:original_to, original_to)
      b.local_variable_set(:support_email, SUPPORT_EMAIL)

      template = File.read('views/mailers/confirm_listing.erb')
      body = ERB.new(template).result(b)

      build_email(to, subject, body)
    end


    private

    def build_email(to_arg, subject_arg, body_arg)
      from_email = Mail.delivery_method.settings[:user_name]
      from_name = 'PDX Daily Dancer'

      Mail.new do
        from     "#{from_name} <#{from_email}>"
        to       to_arg
        subject  subject_arg
        body     body_arg
      end
    end

  end

end
