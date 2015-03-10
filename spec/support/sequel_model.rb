class Sequel::Model

  HAS_ERROR_ON = :has_error_on?

  # Note these methods are only here for
  if instance_methods.include?(HAS_ERROR_ON)
    raise "Sequel::Model already has a method called #{HAS_ERROR_ON}, so bad things could happen if you overwrite it"
  end

  define_method HAS_ERROR_ON do |attribute|
    valid?
    errors.has_key? attribute
  end
end
