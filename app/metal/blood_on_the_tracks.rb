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
                   text = env['rack.input'].read
                   STDERR.puts(text)
                   request = JSON.parse(text)
                   command = request['command']
                   {'result' => command}
                 end

      [200, {"Content-Type" => "application/json"}, [response.to_json]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
