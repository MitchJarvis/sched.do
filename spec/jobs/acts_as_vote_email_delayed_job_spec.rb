require 'spec_helper'

class TestJobClass < Struct.new(:vote_id)
  include ActsAsVoteEmailDelayedJob
end

describe ActsAsVoteEmailDelayedJob, '.error' do
  it 'sends Airbrake an exception if the job fails' do
    vote = build_stubbed(:vote)
    Airbrake.stubs(:notify)
    exception = 'Hey! you did something wrong!'

    job = TestJobClass.new(vote)
    job.error(job, exception)

    Airbrake.should have_received(:notify).with(exception)
  end
end

describe VoteConfirmationEmailJob, '#perform_email_job' do
  it 'calls the block if the vote exists and there is not another vote within the time windows' do
    fake_job = stub(test_message: nil)
    vote = create(:vote)
    Vote.stubs(find_by_id: vote)

    TestJobClass.new(vote.id).perform_email_job { fake_job.test_message }

    fake_job.should have_received(:test_message).once
  end

  it 'quietly fails and logs the error if the Vote is destroyed before the job runs' do
    fake_job = stub(test_message: nil)
    fake_logger = stub(error: 'blah')
    Rails.stubs(logger: fake_logger)
    Vote.stubs(find_by_id: nil)
    vote_id = 0

    TestJobClass.new(vote_id).perform_email_job { fake_job.test_message }

    fake_logger.should have_received(:error).
      with("NOTE: TestJobClass cannot find Vote id=#{vote_id}")
    fake_job.should have_received(:test_message).never
  end

  it 'does not execute the block if there is a new vote by the same user for the event in the time window' do
    fake_job = stub(test_message: nil)
    Vote.any_instance.stubs(:has_no_other_votes_within_delay_window?).returns(false)
    vote = create(:vote)
    Vote.stubs(find_by_id: vote)
    vote_id = 0

    TestJobClass.new(vote_id).perform_email_job { fake_job.test_message }

    fake_job.should have_received(:test_message).never
  end
end
