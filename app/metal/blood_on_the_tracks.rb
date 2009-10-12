# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class BloodOnTheTracks
  def self.call(env)
    if env["PATH_INFO"] =~ %r{^/blood_on_the_tracks/(\d+)$}
      request_id = $1
      metadata = BOTT::TrackRequests.requests[request_id] || {}
      
      [
       200,
       {"Content-Type" => "text/html"},
       [metadata.to_json],
      ]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
