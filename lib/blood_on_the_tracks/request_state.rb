require 'pp'

module BOTT
class RequestState
  include Singleton
  
  attr_reader :current_request_id
  
  def initialize
    @current_request_id = "NOT_INITIALIZED"
    @all_requests_state = {}
  end

  def new_request!
    @current_request_id = rand(2 ** 64).to_s
    add_metadata 'request_id', @current_request_id
  end

  def add_metadata(key, value)
    @all_requests_state[@current_request_id] ||= {}
    @all_requests_state[@current_request_id][key] = value
  end

  def get_metadata(request_id)
    @all_requests_state[request_id]
  end
end
end
