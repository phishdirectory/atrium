# frozen_string_literal: true

# app/helpers/application_helper.rb
module ApplicationHelper
  def flash_class_for(flash_type)
    case flash_type.to_sym
    when :notice, :success
      "bg-green-50 border-l-4 border-green-400 text-green-800"
    when :alert, :error
      "bg-red-50 border-l-4 border-red-400 text-red-800"
    when :warning
      "bg-yellow-50 border-l-4 border-yellow-400 text-yellow-800"
    when :info
      "bg-blue-50 border-l-4 border-blue-400 text-blue-800"
    else
      "bg-gray-50 border-l-4 border-gray-400 text-gray-800"
    end
  end

  def current_page?(path)
    request.path == path
  end

  def relative_timestamp(time, options = {})
    content_tag :span, "#{options[:prefix]}#{time_ago_in_words time} ago#{options[:suffix]}", options.merge(title: time)
  end

  def help_message
    content_tag :span, "Email #{help_email} for support.".html_safe # rubocop:disable Rails/OutputSafety
  end

  def help_email
    mail_to "support@phish.directory"
  end

  def app_version
    @app_version ||= begin
      if Rails.env.development?
        "DEVELOPMENT"
      else
        env = Rails.env.upcase
        time = Time.now.utc.strftime("%Y-%m-%d %H-%M UTC")
        "#{env} @ #{time}"
      end
    end
  end

  def rails_version
    Rails::VERSION::STRING
  end

  def ruby_version
    RUBY_VERSION
  end
end
