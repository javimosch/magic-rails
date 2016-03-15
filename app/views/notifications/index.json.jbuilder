json.array!(@notifications) do |notification|
  json.extract! notification, :id, :type, :title, :content, :sender, :user_id, :meta, :read
  json.url notification_url(notification, format: :json)
end
