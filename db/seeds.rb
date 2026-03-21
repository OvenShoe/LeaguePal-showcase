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

# START Additional Players
player1 = User.create!(
  first_name: "James",
  last_name: "Mitchell",
  date_of_birth: Date.new(1990, 3, 14),
  email: "james.mitchell@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player2 = User.create!(
  first_name: "Sarah",
  last_name: "Thompson",
  date_of_birth: Date.new(1988, 7, 22),
  email: "sarah.thompson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player3 = User.create!(
  first_name: "Daniel",
  last_name: "Carter",
  date_of_birth: Date.new(1993, 1, 5),
  email: "daniel.carter@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player4 = User.create!(
  first_name: "Emily",
  last_name: "Harris",
  date_of_birth: Date.new(1995, 11, 30),
  email: "emily.harris@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player5 = User.create!(
  first_name: "Michael",
  last_name: "Brown",
  date_of_birth: Date.new(1987, 6, 18),
  email: "michael.brown@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player6 = User.create!(
  first_name: "Jessica",
  last_name: "Wilson",
  date_of_birth: Date.new(1992, 9, 3),
  email: "jessica.wilson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player7 = User.create!(
  first_name: "Chris",
  last_name: "Taylor",
  date_of_birth: Date.new(1991, 4, 27),
  email: "chris.taylor@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player8 = User.create!(
  first_name: "Lauren",
  last_name: "Anderson",
  date_of_birth: Date.new(1994, 12, 9),
  email: "lauren.anderson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player9 = User.create!(
  first_name: "Ryan",
  last_name: "Moore",
  date_of_birth: Date.new(1989, 8, 15),
  email: "ryan.moore@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player10 = User.create!(
  first_name: "Megan",
  last_name: "Jackson",
  date_of_birth: Date.new(1996, 2, 21),
  email: "megan.jackson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player11 = User.create!(
  first_name: "Nathan",
  last_name: "White",
  date_of_birth: Date.new(1990, 5, 7),
  email: "nathan.white@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player12 = User.create!(
  first_name: "Amy",
  last_name: "Martin",
  date_of_birth: Date.new(1993, 10, 16),
  email: "amy.martin@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player13 = User.create!(
  first_name: "Tom",
  last_name: "Garcia",
  date_of_birth: Date.new(1986, 7, 29),
  email: "tom.garcia@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player14 = User.create!(
  first_name: "Rachel",
  last_name: "Lee",
  date_of_birth: Date.new(1997, 3, 11),
  email: "rachel.lee@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player15 = User.create!(
  first_name: "Kevin",
  last_name: "Clark",
  date_of_birth: Date.new(1988, 1, 25),
  email: "kevin.clark@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player16 = User.create!(
  first_name: "Nicole",
  last_name: "Lewis",
  date_of_birth: Date.new(1991, 6, 4),
  email: "nicole.lewis@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player17 = User.create!(
  first_name: "Adam",
  last_name: "Robinson",
  date_of_birth: Date.new(1985, 9, 19),
  email: "adam.robinson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player18 = User.create!(
  first_name: "Stephanie",
  last_name: "Walker",
  date_of_birth: Date.new(1994, 4, 8),
  email: "stephanie.walker@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player19 = User.create!(
  first_name: "Brandon",
  last_name: "Hall",
  date_of_birth: Date.new(1992, 11, 13),
  email: "brandon.hall@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player20 = User.create!(
  first_name: "Melissa",
  last_name: "Allen",
  date_of_birth: Date.new(1989, 2, 28),
  email: "melissa.allen@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player21 = User.create!(
  first_name: "Tyler",
  last_name: "Young",
  date_of_birth: Date.new(1996, 8, 6),
  email: "tyler.young@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player22 = User.create!(
  first_name: "Ashley",
  last_name: "King",
  date_of_birth: Date.new(1990, 12, 24),
  email: "ashley.king@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player23 = User.create!(
  first_name: "Jason",
  last_name: "Wright",
  date_of_birth: Date.new(1987, 5, 17),
  email: "jason.wright@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player24 = User.create!(
  first_name: "Samantha",
  last_name: "Scott",
  date_of_birth: Date.new(1993, 7, 31),
  email: "samantha.scott@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player25 = User.create!(
  first_name: "Mark",
  last_name: "Green",
  date_of_birth: Date.new(1984, 3, 2),
  email: "mark.green@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player26 = User.create!(
  first_name: "Brittany",
  last_name: "Adams",
  date_of_birth: Date.new(1995, 10, 20),
  email: "brittany.adams@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player27 = User.create!(
  first_name: "Derek",
  last_name: "Baker",
  date_of_birth: Date.new(1991, 1, 14),
  email: "derek.baker@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player28 = User.create!(
  first_name: "Vanessa",
  last_name: "Nelson",
  date_of_birth: Date.new(1988, 6, 26),
  email: "vanessa.nelson@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player29 = User.create!(
  first_name: "Patrick",
  last_name: "Hill",
  date_of_birth: Date.new(1994, 4, 10),
  email: "patrick.hill@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player30 = User.create!(
  first_name: "Tiffany",
  last_name: "Ramirez",
  date_of_birth: Date.new(1992, 9, 23),
  email: "tiffany.ramirez@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player31 = User.create!(
  first_name: "Sean",
  last_name: "Campbell",
  date_of_birth: Date.new(1986, 12, 1),
  email: "sean.campbell@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player32 = User.create!(
  first_name: "Amber",
  last_name: "Mitchell",
  date_of_birth: Date.new(1997, 5, 9),
  email: "amber.mitchell@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player33 = User.create!(
  first_name: "Gregory",
  last_name: "Turner",
  date_of_birth: Date.new(1983, 8, 22),
  email: "gregory.turner@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player34 = User.create!(
  first_name: "Heather",
  last_name: "Phillips",
  date_of_birth: Date.new(1990, 2, 15),
  email: "heather.phillips@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player35 = User.create!(
  first_name: "Colin",
  last_name: "Evans",
  date_of_birth: Date.new(1993, 7, 3),
  email: "colin.evans@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player36 = User.create!(
  first_name: "Diana",
  last_name: "Parker",
  date_of_birth: Date.new(1989, 11, 28),
  email: "diana.parker@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player37 = User.create!(
  first_name: "Marcus",
  last_name: "Edwards",
  date_of_birth: Date.new(1991, 4, 17),
  email: "marcus.edwards@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player38 = User.create!(
  first_name: "Natalie",
  last_name: "Collins",
  date_of_birth: Date.new(1995, 1, 6),
  email: "natalie.collins@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player39 = User.create!(
  first_name: "Joel",
  last_name: "Stewart",
  date_of_birth: Date.new(1988, 6, 12),
  email: "joel.stewart@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player40 = User.create!(
  first_name: "Kimberly",
  last_name: "Sanchez",
  date_of_birth: Date.new(1996, 3, 25),
  email: "kimberly.sanchez@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player41 = User.create!(
  first_name: "Owen",
  last_name: "Morris",
  date_of_birth: Date.new(1987, 10, 8),
  email: "owen.morris@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)

player42 = User.create!(
  first_name: "Claire",
  last_name: "Rogers",
  date_of_birth: Date.new(1994, 7, 19),
  email: "claire.rogers@leaguepal.com",
  password: "123456",
  password_confirmation: "123456"
)
# END Additional Players

TeamMember.create!(
  team_id: team.id,
  user_id: player.id,
  role: "player"
)
puts "User created: #{player.first_name} #{player.last_name} (#{player.email} 👩🏾‍🏭) and added as Player to team #{team.name} 🏆"

puts "Seed data creation complete! 🎉"
