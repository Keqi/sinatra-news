require_relative 'lib/application'

use Rack::Cache,
      :verbose => true,
      :metastore   => "memcached://localhost:11211/meta",
      :entitystore => "memcached://localhost:11211/body"

run PilotNews::Application
