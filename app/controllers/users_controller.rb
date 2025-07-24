class UsersController < ApplicationController
  def next_course
    user_id = params[:id]
    # Stub: fetch all courses and lessons (in real app, project from events)
    courses = [
      { id: 'course-1', title: 'Ruby 101', lessons: ['lesson-1', 'lesson-2'] },
      { id: 'course-2', title: 'Rails 101', lessons: ['lesson-3', 'lesson-4'] }
    ]
    completed = UserProgressRecord.where(user_id: user_id, completed: true).pluck(:lesson_id)
    next_course = courses.find do |course|
      (course[:lessons] - completed).any?
    end
    next_course ||= courses.first # fallback
    render json: { recommended_course: next_course }
  end
end 