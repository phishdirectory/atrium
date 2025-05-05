# Template Repository

This is a fork of [ruby-rails-template](https://github.com/jaspermayone/ruby-rails-template) by @jaspermayone.

## Setup Guide

### Initial Repository Setup

1. **Create Your Repository**
   Click the "Use this template" button or fork this repository to get started.

2. **Configure GitHub Settings**

   - Import the ruleset: Copy `main-ruleset.yml` from the `.github` folder into your new repository.
   - Set up Dependabot: Rename `.github/dependabot.disabled.yml` to `.github/dependabot.yml` and update for your package ecosystem.
   - Update code ownership: Edit `.github/CODEOWNERS` with appropriate usernames or teams.

3. **Customize This README**
   - Change the title to your repository name
   - Add a project description
   - Include maintainer contact information

### Application Setup

1. **Generate Credentials**

   ```bash
   bin/regenerate-credentials
   ```

2. **Create Lockbox Encryption Key**

   ```ruby
   # Run in Rails console
   Lockbox.generate_key
   ```

3. **Add Key to Credentials**

   ```bash
   rails credentials:edit
   ```

   Then add:

   ```yaml
   lockbox:
     master_key: "your_generated_key_here"
   ```

4. **Replace Placeholder Names**
   Search for and replace all instances of "REPLACEMEWITHAPPNAME" with your application name.

5. **Install Dependencies**

   ```bash
   bundle install
   ```

### Next Steps

You're ready to start development! Consider reviewing:

- Database configuration in `config/database.yml`
- Environment variables in `.env.example` (copy to `.env` for local development)

---

## Example Readme

```markdown
# my-awesome-project

A simple tool to automate phishing domain detection.

Maintainer: @yourusername
Contact: you@example.com
```
