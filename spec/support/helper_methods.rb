def create(model_name, params={})
  case model_name
  when :human
    # rand.to_s generates something like '0.12847366495349'
    default_params = { phone_number: '+1' + rand.to_s[2..11] }
    Human.create(default_params.merge(params))
  end
end
