require_relative 'lib/application'

if memcache_servers = "localhost"
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_servers}",
    entitystore: "memcached://#{memcache_servers}"
end

run PilotNews::Application
