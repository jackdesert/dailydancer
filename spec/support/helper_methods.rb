def create(model_name, params={})
  case model_name
  when :message
    # rand.to_s generates something like '0.12847366495349'
    default_params =  {
                        subject: 'test subject',
                        author: 'test author',
                        plain: 'test plain',
                        html: 'test html',
                        received_at: Time.new(2015, 2, 1, 12)
                      }
    Message.create(default_params.merge(params))
  end
end
