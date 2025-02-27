class Feedback < ActiveRecord::Base
  self.per_page = 25
  belongs_to :tutorial
  belongs_to :coach, class_name: 'Member'
  belongs_to :workshop
  has_one :chapter, through: :workshop

  validates :rating, inclusion: { in: 1..5, message: "can't be blank" }
  validates :tutorial, presence: true
  validate :coach_field_has_a_coach_role?

  def coach_field_has_a_coach_role?
    return false unless coach_id

    unless Member.find(coach_id).groups.coaches.any?
      errors.add(:coach, "Coach member doesn't have 'coach' role.")
    end
  end

  def self.submit_feedback(params, token)
    return false unless feedback_request = FeedbackRequest.find_by(token: token)

    feedback = Feedback.new(params)
    feedback.workshop = feedback_request.workshop

    if feedback.valid? && !feedback_request.submited
      feedback_request.update(submited: true)
      feedback.save
    else
      false
    end
  end
end
