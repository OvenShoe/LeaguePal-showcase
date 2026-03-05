require "test_helper"

class TeamInvitationMailerTest < ActionMailer::TestCase
  test "invite_email" do
    user = User.create!(email: "inviter@test.com", password: "password")
    admin = CompetitionAdmin.create!(user_id: user.id)
    competition = Competition.create!(name: "Test Competition", sport: "Basketball", start_date: Date.today, end_date: 1.month.from_now, competition_admin_id: admin.id)
    team = Team.create!(name: "Test Team", competition: competition)
    invitation = TeamInvitation.create!(
      team: team,
      inviter: user,
      invitee_email: "invitee@test.com",
      token_digest: BCrypt::Password.create("test_token")
    )

    email = TeamInvitationMailer.invite_email(invitation, "test_token").deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ "invitee@test.com" ], email.to
    assert_equal "You've been invited to join team id:#{team.id} on LeaguePal!", email.subject
  end
end
