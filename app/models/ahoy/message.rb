# frozen_string_literal: true

module Ahoy
  class Message < ApplicationRecord
    self.table_name = "ahoy_messages"

    belongs_to :user, polymorphic: true, optional: true

    has_encrypted :to
    blind_index :to

  end
end
