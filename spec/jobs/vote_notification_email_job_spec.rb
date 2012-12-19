require 'spec_helper'

describe VoteConfirmationEmailJob, '.enqueue' do
  it 'enqueues the job' do
    Timecop.freeze do
      vote = build_stubbed(:vote)

      VoteNotificationEmailJob.enqueue(vote)

      should enqueue_delayed_job('VoteNotificationEmailJob').
        with_attributes(vote_id: vote.id).
        priority(1).
        run_at(3.minutes.from_now)
    end
  end
end


describe VoteConfirmationEmailJob, '#perform' do
  it 'sends the vote_notification message to UserMailer' do
    mailer = stub('mailer', deliver: true)
    UserMailer.stubs(vote_notification: mailer)
    vote = build_stubbed(:vote)
    Vote.stubs(find_by_id: vote)

    VoteNotificationEmailJob.new.perform

    UserMailer.should have_received(:vote_notification).with(vote)
  end
end
