# THIS IS NOT THREAD-SAFE!!
module BOTT
  
class TrackRequests
  
  cattr_reader :requests
  
  def initialize(app)
    @app = app
    @@requests = {}
  end

  def call(env)
    if (env['PATH_INFO'] =~ /blood_on_the_tracks/)
      # skip this middleware
      @app.call(env)
    else
      # generate a new request id; other hooks use this to instrument the request
      @@request_id = rand(2 ** 64).to_s
    
      @status, @headers, @response = @app.call(env)
      @headers['X-BOTT-Request-Id'] = @@request_id
    
      [@status, @headers, @response]
    end
  end
end

end
