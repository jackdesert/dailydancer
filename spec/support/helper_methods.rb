def create(model_name, params={})
  case model_name
  when :message
    # rand.to_s generates something like '0.12847366495349'
    default_params =  { subject: 'test subject',
                        author: 'test author',
                        plain: 'test plain',
                        html: 'test html',
                      }
    Message.create(default_params.merge(params))
  end
end
