class VoteNotificationEmailJob < Struct.new(:vote_id)
  include ActsAsVoteEmailDelayedJob

  def self.enqueue(vote)
    Delayed::Job.enqueue(
      new(vote.id),
      run_at: DELAY.from_now,
      priority: PRIORITY
    )
  end

  def perform
    perform_email_job do
      send_notification_email
    end
  end

  private

  def send_notification_email
    UserMailer.vote_notification(vote).deliver
  end
end
