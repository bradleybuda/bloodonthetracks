# THIS IS NOT THREAD-SAFE!!
module BOTT
  
class TrackRequests
  
  cattr_reader :request_id
  cattr_reader :requests
  
  def initialize(app)
    @app = app
  end

  def call(env)
    @@requests ||= {}
    
    if (env['PATH_INFO'] =~ /blood_on_the_tracks/)
      # skip this middleware
      @app.call(env)
    else
      # generate a new request id; other hooks use this to instrument the request
      RequestState.instance.new_request!

      @status, @headers, @response = @app.call(env)
      @headers['X-BOTT-Request-Id'] = RequestState.instance.current_request_id
    
      [@status, @headers, @response]
    end
  end
end

end
