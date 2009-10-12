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

# Spy on render
module ::ActionController
  class Base
    def render_with_bott(*args)
      caller(0).each do |stack_line|
        if stack_line =~ %r{app/controllers/(.*)\.rb:\d+:in \`(.*)\'}
          state = BOTT::RequestState.instance
          state.add_metadata 'controller', $1
          state.add_metadata 'action', $2
          break
        end
      end
      
      render_without_bott(*args)
    end

    alias_method_chain :render, :bott
  end
end
