require 'rails_helper'
require 'securerandom'

describe 'Recommendation API', type: :request do
  let(:user_id) { SecureRandom.uuid }
  let(:lesson_id) { SecureRandom.uuid }

  before do
    # Seed some progress with valid UUIDs
    UserProgressRecord.create!(user_id: user_id, lesson_id: lesson_id, completed: true)
  end

  it 'recommends the next course for a user' do
    get "/users/#{user_id}/next-course"
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body['recommended_course']).to be_present
    # Optionally, check for course id if you have seeded courses
    # expect(body['recommended_course']['id']).to eq('course-1')
  end

  it 'recommends a course for a new user' do
    new_user_id = SecureRandom.uuid
    get "/users/#{new_user_id}/next-course"
    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body['recommended_course']).to be_present
  end
end 
