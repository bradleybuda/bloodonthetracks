module BloodOnTheTracks
class Server
    
  def initialize(app)
    @app = app
  end
  
  def call(env)
    case env["PATH_INFO"]
    when %r{^/blood_on_the_tracks/(\d+)/(.+)$}
      api_call(env, $1, $2)
    else
      instrument_request(env)
    end
  end
  
  private

  def instrument_request(env)
    # generate a new request id; other hooks use this to instrument the request
    RequestState.instance.new_request!

    @status, @headers, @response = @app.call(env)
    @headers['X-BOTT-Request-Id'] = RequestState.instance.current_request_id
    
    [@status, @headers, @response]
  end
  
  def api_call(env, request_id, method)
    metadata = BloodOnTheTracks::RequestState.instance.get_metadata(request_id)

    response = case method
               when 'metadata'
                 metadata
               when 'eval'
                 request = JSON.parse(env['rack.input'].read)
                 command = request['command']
                   
                 # eval this command in the context of the controller's instance variables
                 instance_vars = metadata['instance_variables']

                 begin
                   o = Object.new
                   instance_vars.each { |name, value| o.instance_variable_set(name, value) }

                   # if the user defines any variables, unfortunately, they get lost here
                   # we could persist +o+ to keep them around...
                   
                   result = o.instance_eval(command)
                   
                   {'result' => result.pretty_inspect.chomp, 'error' => false}
                 rescue => e
                   {'result' => e.to_s, 'error' => true}
                 end
               end
    
    # TODO maybe text/plain for nice debugging?
    [200, {"Content-Type" => "application/json"}, [response.to_json]]
  end
  
end
end

