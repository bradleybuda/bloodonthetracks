# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = true # need to make this true to support BOTT for now

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# Hook up blood_on_the_tracks
config.middleware.insert_after(ActionController::Failsafe, BOTT::TrackRequests)

# Spy on all controller actions
require 'pp'
module ::ActionController
  class Dispatcher
    BOTT_DEFAULT_INSTANCE_VARS = ["@_current_render", "@template", "@assigns_added", "@view_paths", "@_first_render", "@output_buffer", "@assigns", "@helpers", "@cached_content_for_layout", "@template_format", "@controller", "@content_for_layout", "@_request"]
    
    def bott_after_request
      STDERR.puts "intercepting request"
      
      original_request = @env['action_controller.rescue.request']
      original_response = @env['action_controller.rescue.response']
      view = original_response.template
      instance_vars = {}
      
      (view.instance_variables - BOTT_DEFAULT_INSTANCE_VARS).each do |ivar_name|
        instance_vars[ivar_name] = view.instance_variable_get(ivar_name).pretty_inspect
      end
      
      state = BOTT::RequestState.instance
      
      state.add_metadata 'controller', original_request.params[:controller]
      state.add_metadata 'action', original_request.params[:action]
      state.add_metadata 'params', original_request.params
      state.add_metadata 'instance_variables', instance_vars
    end
    
    after_dispatch :bott_after_request
  end
end
