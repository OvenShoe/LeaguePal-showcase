temp_comp_admin_user = User.create!(
  first_name: "Admin",
  last_name: "Test",
  email: "at@example.com",
  password: "secret1!",
  password_confirmation: "secret1!",
  date_of_birth: Date.new(1900, 1, 1),
  role: "Admin",
  team_id: nil
)


temp_comp_admin = CompetitionAdmin.create!(user: temp_comp_admin_user)

temp_competition = Competition.create!(competition_admin: temp_comp_admin)

temp_team = Team.create!(
  name: "Temp Team",
  competition: temp_competition,
  wins: 0,
  losses: 0,
  draws: 0,
  games_played: 0,
  competition_points: 0,
  points_for: 0,
  points_against: 0,
  form: []
)

temp_comp_admin_user.update!(team: temp_team)

competition = Competition.create!(competition_admin: temp_comp_admin)

team = Team.create!(
  name: "Gack Zalifiniakis",
  competition: competition,
  wins: 0,
  losses: 0,
  draws: 0,
  games_played: 0,
  competition_points: 0,
  points_for: 0,
  points_against: 0,
  form: []
)

User.create!(
  first_name: "Bradley",
  last_name: "Cooper",
  date_of_birth: Date.new(1975, 1, 5),
  email: "bc@test.com",
  password: "secret1!",
  password_confirmation: "secret1!",
  team: team,
  role: "Captain",
  team_position: "Goal Attack (GA)"
)

User.create!(
  first_name: "Zack",
  last_name: "Galifianakis",
  date_of_birth: Date.new(1969, 10, 1),
  email: "zg@test.com",
  password: "secret1!",
  password_confirmation: "secret1!",
  team: team,
  role: "Player",
  team_position: "Goal Defence (GD)"
)
