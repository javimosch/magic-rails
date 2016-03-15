json.array!(@ratings) do |rating|
  json.extract! rating, :id, :to_user_id, :from_user_id, :type
  json.url rating_url(rating, format: :json)
end
