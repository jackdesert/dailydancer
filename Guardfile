# A sample Guardfile
# More info at https://github.com/guard/guard#readme

group :views do
  guard 'livereload' do
    watch(%r{views/.+\.(erb|haml|slim)$})
    watch(%r{helpers/.+\.rb})
    watch(%r{public/.+css})
    watch(%r{public/.+js})
  end
end

guard 'rspec', cmd: 'bundle exec rspec' do

  # Model files
  watch(%r{^models/(.+)\.rb$})                           { |m| "spec/models/#{m[1]}_spec.rb" }
  watch(%r{^presenters/(.+)\.rb$})                           { |m| "spec/presenters/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})

end

