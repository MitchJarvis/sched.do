step ':email_address should receive an email' do |email_address|
  unread_emails_for(email_address).size.should == 1
end

step ':email_address should receive an email with the text :email_text' do |email_address, email_text|
  unread_emails_for(email_address).size.should == 1
  email_body(last_email_sent).should =~ /#{Regexp.escape(email_text)}/
end

step ':email_address follows the link :link in his email' do |email_address, link|
  open_email(email_address)
  visit_in_email(link)
end

step ':email_address should receive a vote confirmation email with a link to :event_name' do |email_address, event_name|
  event = Event.find_by_name(event_name)
  guest = event.invitees.first
  body = email_body(last_email_sent)
  body.should have_link('Click Here', href: event_url(event, guest_email: guest.email))
  body.should include('Thanks for voting!')
end

step ':email_address should receive a reminder email with a link to :event_name' do |email_address, event_name|
  event = Event.find_by_name(event_name)
  guest = event.invitees.first
  body = email_body(last_email_sent)
  body.should have_link('Click Here', href: event_url(event, guest_email: guest.email))
  body.should include('Reminder to vote')
end

step ':email_address should receive an invitation email with a link to :event_name' do |email_address, event_name|
  event = Event.find_by_name(event_name)
  guest = event.invitees.first
  body = email_body(last_email_sent)
  body.should have_link('Click Here', href: event_url(event, guest_email: guest.email))
  body.should include('invited')
end

step ':email_address should have :count email(s)' do |email_address, count|
  mailbox_for(email_address).size.should == count.to_i
end

step 'out-network Yammer user :name should get an email notification' do |name|
  user = User.find_by_name!(name)
  mailbox_for(user.email).size.should == 1
end

step 'the email should contain an image of the owner of :event_name' do |event_name|
  event = Event.find_by_name(event_name)
  email_body(last_email_sent).should include(event.owner.image)
end

step 'the email should contain an image of :user_name' do |user_name|
  user = User.find_by_name(user_name)
  email_body(last_email_sent).should include(user.image)
end
