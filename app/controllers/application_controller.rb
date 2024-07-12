class ApplicationController < ActionController::Base
  before_action :authenticate_staff!
end
