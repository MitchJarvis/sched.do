require 'spec_helper'

describe VoteConfirmationEmailJob, '.enqueue' do
  it 'enqueues the job' do
    Timecop.freeze do
      vote = build_stubbed(:vote)

      VoteConfirmationEmailJob.enqueue(vote)

      should enqueue_delayed_job('VoteConfirmationEmailJob').
        with_attributes(vote_id: vote.id).
        priority(1).
        run_at(3.minutes.from_now)
    end
  end
end


describe VoteConfirmationEmailJob, '#perform' do
  it 'sends the vote_confirmation message to Usermailer' do
    mailer = stub('mailer', deliver: true)
    UserMailer.stubs(vote_confirmation: mailer)
    vote = build_stubbed(:vote)
    Vote.stubs(find_by_id: vote)

    VoteConfirmationEmailJob.new.perform

    UserMailer.should have_received(:vote_confirmation).with(vote)
  end
end
