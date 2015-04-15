require 'rack'
require 'rack/server'

class HelloWorld
  def response
    [200, {}, ['Hello World']]
  end
end

module PilotNews
  class Application
    def self.call(env)
      HelloWorld.new.response
    end
  end
end