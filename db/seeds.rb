puts "Clearing Users and Competition Admins..."
User.destroy_all
CompetitionAdmin.destroy_all

puts "Creating User 👷🏾‍♀️"
admin1 = User.create!(email: "no@email.com", password: "secret")
puts "Creating Competition Admins 🧑🏾‍💼"
CompetitionAdmin.create!(user: admin1)
puts "Seeding complete! 🌱"
