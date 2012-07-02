class Invitation < ActiveRecord::Base
  attr_accessible :event, :invitee

  belongs_to :event
  belongs_to :invitee, polymorphic: true

  accepts_nested_attributes_for :invitee

  validates :event_id, presence: true
  validates :invitee_id, presence: true
  validates :invitee_type, presence: true

  def self.find_or_create_by_event_and_invitee(event, invitee)
    find_or_create_by_event_id_and_invitee_id_and_invitee_type(event.id, invitee.id, invitee.class.name)
  end

  def self.create_with_event_from_params(event, params)
    params.values.each do |invitation|
      if invitation[:yammer_user_id].present?
        User.invite(event, invitation)
      else
        Guest.invite(event, invitation[:name_or_email])
      end
    end
  end

  def name_or_email
    invitee.try(:name) || invitee.try(:email)
  end

  def yammer_user_id
    invitee.try(:yammer_user_id)
  end
end
