# hacked in for now
if RAILS_ENV == 'development'
  require 'pp'
  require 'blood_on_the_tracks/request_state'

  # Tell Dispatcher to call our code to track requests
  # TODO externalize
  module ::ActionController
    class Dispatcher
      BOTT_DEFAULT_INSTANCE_VARS = ["@_current_render", "@template", "@assigns_added", "@view_paths", "@_first_render", "@output_buffer", "@assigns", "@helpers", "@cached_content_for_layout", "@template_format", "@controller", "@content_for_layout", "@_request"]
    
      def bott_after_request
        original_request = @env['action_controller.rescue.request']
        original_response = @env['action_controller.rescue.response']
        view = original_response.template
        instance_variables = {}
        instance_variables_pretty = {}
      
        (view.instance_variables - BOTT_DEFAULT_INSTANCE_VARS).each do |ivar_name|
          instance_variables[ivar_name] = view.instance_variable_get(ivar_name).dup rescue nil
          instance_variables_pretty[ivar_name] = view.instance_variable_get(ivar_name).pretty_inspect
        end
      
        state = ::BloodOnTheTracks::RequestState.instance
       
        state.add_metadata 'controller', original_request.params[:controller]
        state.add_metadata 'action', original_request.params[:action]
        state.add_metadata 'params', original_request.params
        state.add_metadata 'instance_variables', instance_variables
        state.add_metadata 'instance_variables_pretty', instance_variables_pretty
      end
    
      after_dispatch :bott_after_request
    end
  end
end
