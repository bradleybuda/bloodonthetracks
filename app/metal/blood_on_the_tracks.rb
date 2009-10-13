# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class BloodOnTheTracks
  def self.call(env)
    if env["PATH_INFO"] =~ %r{^/blood_on_the_tracks/(\d+)/(.+)$}
      request_id = $1
      method = $2

      STDERR.puts "calling #{method} on request #{request_id}"

      response = case method
                 when 'metadata'
                   BOTT::RequestState.instance.get_metadata(request_id)
                 when 'eval'
                   request = JSON.parse(env['rack.input'].read)
                   command = request['command']
                   
                   # eval this command in the context of the controller's instance variables
                   instance_vars = BOTT::RequestState.instance.get_metadata(request_id)['instance_variables']
                   o = Object.new
                   instance_vars.each do |name, value|
                     o.instance_variable_set(name, value)
                   end
                   
                   result = o.instance_eval(command)
                   {'result' => result.pretty_inspect}
                 end

      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
