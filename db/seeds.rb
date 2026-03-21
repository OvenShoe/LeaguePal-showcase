Stat.delete_all
puts "Clearing Stats..."
Trophy.delete_all
puts "Clearing Trophies..."
Game.delete_all
puts "Clearing Games..."
Round.delete_all
puts "Clearing Rounds..."
TeamInvitation.delete_all
puts "Clearing Team Invitations..."
TeamMember.delete_all
puts "Clearing Team Members..."
Team.delete_all
puts "Clearing Teams..."
Competition.delete_all
puts "Clearing Competitions..."
CompetitionAdmin.delete_all
puts "Clearing Competition Admins..."
User.delete_all
puts "Clearing Users..."
puts "Clearing complete! 🧹"

puts "Creating seed data..."
puts "Creating temporary competition admin user, competition, and team for associations...🏗"
temp_comp_admin_user = User.create!(
  first_name: "Admin",
  last_name: "Test",
  email: "at@example.com",
  password: "secret1!",
  password_confirmation: "secret1!",
  date_of_birth: Date.new(1900, 1, 1),
  )

puts "User created: #{temp_comp_admin_user.first_name} #{temp_comp_admin_user.last_name} (#{temp_comp_admin_user.email} 👩🏾‍🏭)"
temp_comp_admin = CompetitionAdmin.create!(user_id: temp_comp_admin_user.id)
puts "CompetitionAdmin created for user: #{temp_comp_admin.user.first_name} 💻"

competition = Competition.create!(competition_admin_id: temp_comp_admin.id, sport: "Netball")
puts "Competition created: #{competition.name} 🥍"

competition_2 = Competition.create!(name: "Test League", sport: "Football", competition_admin_id: temp_comp_admin.id)
round = Round.create!(competition: competition_2, name: "Round 1")

puts "Creating team and users for associations...🏗"

user1 = User.create!(
  first_name: "Alice",
  last_name: "Smith",
  email: "alice@example.com",
   password: "password"
)

user2 = User.create!(
  first_name: "Bob",
  last_name: "Jones",
  email: "bob@example.com",
  password: "password"
)
team1 = Team.create!(name: "Red Rockets", competition_id: competition_2.id)
team2 = Team.create!(name: "Blue Blasters", competition_id: competition_2.id)

team1.team_members.create!(user_id: user1.id)
team2.team_members.create!(user_id: user2.id)

round = Round.create!(competition_id: competition_2.id, name: "Frog Round")
game = Game.create!(round_id: round.id, team_1_id: team1.id, team_2_id: team2.id)
Stat.create!(game: game, user: user1, label: "goals", value: 3)
Stat.create!(game: game, user: user2, label: "goals", value: 2)
Stat.create!(game: game, user: user1, label: "assists", value: 1)
Stat.create!(game: game, user: user2, label: "assists", value: 2)
Stat.create!(game: game, user: user1, label: "tackles", value: 5)
Stat.create!(game: game, user: user2, label: "tackles", value: 7)
Stat.create!(game: game, user: user1, label: "shots", value: 4)
Stat.create!(game: game, user: user2, label: "shots", value: 4)



team = Team.create!(
  name: "Gack Zalifiniakis",
  competition_id: competition.id,
  wins: 0,
  losses: 0,
  draws: 0,
  games_played: 0,
  competition_points: 0,
  points_for: 0,
  points_against: 0,
  form: []
)
puts "Team created: #{team.name} 🏆"

puts "Creating users and team members...🏗"
captain = User.create!(
  first_name: "Bradley",
  last_name: "Cooper",
  date_of_birth: Date.new(1975, 1, 5),
  email: "bc@test.com",
  password: "secret1!",
  password_confirmation: "secret1!"
)

TeamMember.create!(
  team_id: team.id,
  user_id: captain.id,
  role: "captain"
)
puts "User created: #{captain.first_name} #{captain.last_name} (#{captain.email} 👩🏾‍🏭) and added as Captain to team #{team.name} 🏆"



player = User.create!(
  first_name: "Zack",
  last_name: "Galifianakis",
  date_of_birth: Date.new(1969, 10, 1),
  email: "zg@test.com",
  password: "secret1!",
  password_confirmation: "secret1!"
)

TeamMember.create!(
  team_id: team.id,
  user_id: player.id,
  role: "player"
)
puts "User created: #{player.first_name} #{player.last_name} (#{player.email} 👩🏾‍🏭) and added as Player to team #{team.name} 🏆"

puts "Seed data creation complete! 🎉"
