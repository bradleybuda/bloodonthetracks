require 'pp'

# THIS IS NOT THREAD-SAFE!!
module BOTT
class TrackRequests
  
  def initialize(app)
    @app = app
  end

  def call(env)
    @@request_id = rand(2 ** 64).to_s
    
    STDERR.puts "BOTT::TrackRequests call, request_id = #{@@request_id}"
    @status, @headers, @response = @app.call(env)

    @headers['X-BOTT-Request-Id'] = @@request_id
    
    [@status, @headers, @response]
  end
end
end
