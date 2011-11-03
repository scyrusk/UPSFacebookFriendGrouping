# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :mailer_set_url_options

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
    def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end
end
