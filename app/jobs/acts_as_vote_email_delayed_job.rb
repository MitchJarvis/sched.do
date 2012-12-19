module ActsAsVoteEmailDelayedJob
  PRIORITY = 1
  DELAY = 3.minutes

  def perform_email_job
    if vote && no_other_recent_votes
      yield
    end
  end

  def error(job, exception)
    Airbrake.notify(exception)
  end

  private

  def vote
    @vote ||= find_vote || log_error_and_return_false
  end

  def find_vote
    Vote.find_by_id(vote_id)
  end

  def log_error_and_return_false
    log_error
    return false
  end

  def log_error
    Rails.logger.
      error "NOTE: #{self.class} cannot find Vote id=#{vote_id}"
  end

  def no_other_recent_votes
    vote.has_no_other_votes_within_delay_window?
  end
end
