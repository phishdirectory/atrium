# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding data..."

# Create admin user
admin = User.find_or_create_by(email: "admin@phish.directory") do |user|
  user.first_name = "Admin"
  user.last_name = "User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.access_level = :admin
  puts "Created admin user: #{user.email}"
end

# Create regular users
user1 = User.find_or_create_by(email: "john@phish.directory") do |user|
  user.first_name = "John"
  user.last_name = "Doe"
  user.password = "password123"
  user.password_confirmation = "password123"
  puts "Created user: #{user.email}"
end

user2 = User.find_or_create_by(email: "jane@phish.directory") do |user|
  user.first_name = "Jane"
  user.last_name = "Smith"
  user.password = "password123"
  user.password_confirmation = "password123"
  puts "Created user: #{user.email}"
end

# Clear any existing emails (for re-seeding)
Email.destroy_all

# Create sample emails for user1
[
  {
    subject: "Welcome to Atrium",
    body: "Hello #{user1.first_name},\n\nWelcome to Atrium, the email client for phish.directory staff. We're excited to have you on board!\n\nBest regards,\nThe Atrium Team",
    sender: "support@mail.phish.directory",
    received_at: 3.days.ago
  },
  {
    subject: "Meeting Tomorrow",
    body: "Hi #{user1.first_name},\n\nJust a reminder that we have a team meeting tomorrow at 10 AM.\n\nSee you there!\n\nJane",
    sender: user2.mailbox.email_address,
    received_at: 1.day.ago
  },
  {
    subject: "Project Status Update",
    body: "Dear #{user1.first_name},\n\nI'm writing to inform you that the latest phishing detection project is now 75% complete. We expect to finish by next Friday.\n\nRegards,\nAdmin",
    sender: admin.mailbox.email_address,
    received_at: 12.hours.ago
  }
].each do |email_data|
  email = user1.mailbox.emails.create!(
    subject: email_data[:subject],
    body: email_data[:body],
    sender: email_data[:sender],
    recipient: user1.mailbox.email_address,
    received_at: email_data[:received_at],
    message_id: "<#{SecureRandom.uuid}@mail.phish.directory>"
  )
  puts "Created email: #{email.subject} for #{user1.email}"
end

# Create sample sent emails for user1
[
  {
    subject: "Progress Report",
    body: "Hello Admin,\n\nHere's my progress report for this week. I've identified 12 new phishing domains and added them to our database.\n\nBest,\n#{user1.first_name}",
    recipient: admin.mailbox.email_address,
    sent_at: 2.days.ago
  },
  {
    subject: "Question about the new tool",
    body: "Hi Jane,\n\nI have a question about the new scanning tool. Could you show me how to use the advanced features?\n\nThanks,\n#{user1.first_name}",
    recipient: user2.mailbox.email_address,
    sent_at: 6.hours.ago
  }
].each do |email_data|
  email = user1.mailbox.emails.create!(
    subject: email_data[:subject],
    body: email_data[:body],
    sender: user1.mailbox.email_address,
    recipient: email_data[:recipient],
    sent_at: email_data[:sent_at],
    message_id: "<#{SecureRandom.uuid}@mail.phish.directory>"
  )
  puts "Created sent email: #{email.subject} from #{user1.email}"
end

# Create a starred email for user1
starred_email = user1.mailbox.emails.create!(
  subject: "Important: Security Alert",
  body: "Dear #{user1.first_name},\n\nWe've detected unusual activity on our network. Please change your password immediately.\n\nSecurity Team",
  sender: "security@mail.phish.directory",
  recipient: user1.mailbox.email_address,
  received_at: 2.days.ago,
  starred: true,
  message_id: "<#{SecureRandom.uuid}@mail.phish.directory>"
)
puts "Created starred email: #{starred_email.subject} for #{user1.email}"

# Create an archived email for user1
archived_email = user1.mailbox.emails.create!(
  subject: "Old Newsletter",
  body: "This month's newsletter...",
  sender: "newsletter@mail.phish.directory",
  recipient: user1.mailbox.email_address,
  received_at: 30.days.ago,
  archived: true,
  message_id: "<#{SecureRandom.uuid}@mail.phish.directory>"
)
puts "Created archived email: #{archived_email.subject} for #{user1.email}"

puts "Seeding complete!"
