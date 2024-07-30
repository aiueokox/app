# app/services/base_request_service.rb
class BaseRequestService
  def initialize(request)
    @request = request
  end

  protected

  def update_request_status(new_status, approver = nil)
    @request.update!(status: new_status, approver: approver)
  end
end
