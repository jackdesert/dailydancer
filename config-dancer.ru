require './dancer'

require 'logger'

# Patching the Logger class so that it knows how to write
# see https://github.com/customink/stoplight/issues/14
class ::Logger
  alias_method :write, :<<
end

logger = Logger.new(Dancer::LOG_FILE)

use Rack::CommonLogger, logger

# rack/cache is required in production, but
# is not inside a conditional "if" here because
# sometimes rack testing is done in development
# mode with the force_cache param
#
#
use Rack::Cache,
  metastore:   'file:cache/rack/meta',
  entitystore: 'file:cache/rack/body'


run Dancer
