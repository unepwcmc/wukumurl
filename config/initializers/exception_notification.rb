require 'exception_notification/rails'
require 'yaml'

ExceptionNotification.configure do |config|
  config.ignore_if do |exception, options|
    not (Rails.env.production? || Rails.env.staging?)
  end

  config.add_notifier :slack, {
    webhook_url: Rails.application.secrets.slack_notification_webhook_url,
    channel: "#wcmc_io",
    username: "Exception Notification (#{Rails.env})"
  }
end
