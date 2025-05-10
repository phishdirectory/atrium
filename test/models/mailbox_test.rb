# frozen_string_literal: true

# == Schema Information
#
# Table name: mailboxes
#
#  id            :bigint           not null, primary key
#  email_address :string           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  profile_id    :bigint           not null
#
# Indexes
#
#  index_mailboxes_on_email_address  (email_address) UNIQUE
#  index_mailboxes_on_profile_id     (profile_id)
#
require "test_helper"

class MailboxTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
