# Atrium

Atrium is an email client for phish.directory staff. It provides a modern, user-friendly interface for sending and receiving emails with your personalized <username@mail.phish.directory> email address.

## Features

- **User Authentication**: Secure login system for staff members
- **Email Management**: Send, receive, and organize emails
- **Conversation Threading**: View email conversations in a threaded format
- **Rich Text Editing**: Compose emails with rich text formatting
- **Email Organization**: Star, archive, and mark emails as read/unread
- **Modern UI**: Clean, responsive interface using Tailwind CSS

## Setup Instructions

### Prerequisites

- Ruby 3.4.2
- PostgreSQL
- Rails 8.0.2

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/phish-directory/atrium.git
   cd atrium
   ```

2. Install dependencies:

   ```sh
   bundle install
   ```

3. Set up the database:

   ```sh
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. Set up Action Text and Action Mailbox:

   ```sj
   bin/rails action_text:install
   bin/rails action_mailbox:install
   bin/rails db:migrate
   ```

5. Start the Rails server:

   ```sh
   bin/rails server
   ```

6. Access the application at <http://localhost:3000>

### Configuration

#### Email Configuration

To configure Action Mailbox for receiving emails, edit your credentials:

```sh
bin/rails credentials:edit
```

Add the following configuration:

```yaml
action_mailbox:
  ingress_password: your_secure_password

smtp_settings:
  address: smtp.your-email-provider.com
  port: 587
  domain: mail.phish.directory
  user_name: your_username
  password: your_password
  authentication: plain
  enable_starttls_auto: true
```

#### Mail Routing

For production, set up your mail routing to forward emails to the Action Mailbox endpoint:

```txt
https://yourdomain.com/rails/action_mailbox/postmark/inbound_emails
```

## Development

### Sample Accounts

After running `rails db:seed`, the following accounts will be available (only in development):

- Admin User:

  - Email: <admin@phish.directory>
  - Password: password123

- Regular Users:

  - Email: <john@phish.directory>
  - Password: password123

  - Email: <jane@phish.directory>
  - Password: password123

### Testing Email Functionality

For development, you can test email receiving functionality using:

1. The Rails console:

   ```ruby
   # Create a test inbound email
   ActionMailbox::InboundEmail.create_and_extract_message_id!(
     from: "sender@example.com",
     to: "username@mail.phish.directory",
     subject: "Test Subject",
     body: "This is a test email body."
   )
   ```

2. Letter Opener Web (for outgoing emails):
   - Send an email through the application
   - View it at <http://localhost:3000/letter_opener>

## License

This project is licensed under the GNU General Public License v3.0.

## Contact

For any questions or support, please contact the phish.directory team.
