require 'rest-client'
require 'json'
require 'jwt'
require 'securerandom'

class UsersController < ApplicationController
  LMS_JWT_SECRET = 'my$ecretK3y'

  def next_course
    user_id = params[:id]
    # Ensure user_id is a valid UUID
    unless user_id.present? && user_id.match?(/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/)
      user_id = SecureRandom.uuid
    end
    lms_base = ENV.fetch('LMS_API_URL', 'http://lms:3000')
    # Always generate a valid JWT for internal LMS API calls
    token = JWT.encode({ user_id: user_id }, LMS_JWT_SECRET, 'HS256')
    headers = { Authorization: "Bearer #{token}" }

    courses_resp = RestClient.get("#{lms_base}/courses", headers)
    courses = JSON.parse(courses_resp.body)
    courses = courses['data'] if courses.is_a?(Hash) && courses['data']
    # Recommend the first course with completion_percent < 100
    next_course = courses.find { |course| course['completion_percent'].to_i < 100 }
    next_course ||= courses.first
    render json: { recommended_course: next_course }
  end
end 