require './dancer'

require 'logger'

# Patching the Logger class so that it knows how to write
# see https://github.com/customink/stoplight/issues/14
class ::Logger
  alias_method :write, :<<
end

logger = Logger.new(Dancer::LOG_FILE)

use Rack::CommonLogger, logger

# rack/cache is available in all environments
# because it makes it easy to test cache in development
# by passing the allow_cache parameter
use Rack::Cache,
  metastore:   'file:cache/rack/meta',
  entitystore: 'file:cache/rack/body'


run Dancer
