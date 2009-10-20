module BloodOnTheTracks
class Server
  def self.call(env)
    if env["PATH_INFO"] =~ %r{^/blood_on_the_tracks/(\d+)/(.+)$}
      request_id = $1
      method = $2
      
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

      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
end

