class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform(type, order)
    # Notification.create(receiver: current_user, sender: current_user, on_click_url: url,
    #   title: 'Hello', content: 'How are you?')
    # ActionCable.server.broadcast 'notifications:#{notification.receiver_id}', counter: render_counter(notification.receiver.notifications.count), layout: render_notification(notification)
  end

  private

  def render_counter(counter)
    ApplicationController.renderer.render(partial: 'notifications/counter', locals: { counter: counter })
  end

  def render_notification(notification)
    ApplicationController.renderer.render(partial: 'notifications/notification', locals: {notification: notification})
  end
end
