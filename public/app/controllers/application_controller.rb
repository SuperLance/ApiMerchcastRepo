class ApplicationController < ActionController::API
  rescue_from Exception, with: lambda { |exception| render_error exception }
  rescue_from ActiveRecord::RecordNotFound, with: lambda { |exception| record_not_found exception }

  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization


  def check_admin
    render json: {error_message: "Must be an admin user"}, :status => 403 unless current_user.admin?
  end

  def record_not_found(e)
    Rails.logger.error e.class.to_s
    Rails.logger.error e.to_s
    Rails.logger.error e.backtrace.join("\n")
    render json: {error_message: "Record not found", return_code: 404}, :status => 404
  end

  def render_error(e)
    Rails.logger.error e.class.to_s
    Rails.logger.error e.to_s
    Rails.logger.error e.backtrace.join("\n")
    render json: {error_message: "An error has occurred", return_code: 500}, :status => 500
  end
end
