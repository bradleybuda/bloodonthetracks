require 'pp'

module BOTT
class TrackRequests
  def initialize(app)
    STDERR.puts "BOTT::TrackRequests init"
    @app = app
  end

  def call(env)
    STDERR.puts "BOTT::TrackRequests call"
    # is this for thread safety?
    dup._call(env)
  end
  
  def _call(env)
    @status, @headers, @response = @app.call(env)
    [@status, @headers, @response]
  end

end
end
