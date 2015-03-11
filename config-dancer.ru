require './dancer'

require 'logger'

# Patching the Logger class so that it knows how to write
# see https://github.com/customink/stoplight/issues/14
class ::Logger
  alias_method :write, :<<
end

logger = Logger.new(Dancer::LOG_FILE)

use Rack::CommonLogger, logger

run Dancer
