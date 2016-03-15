json.array!(@schedules) do |schedule|
  json.extract! schedule, :id, :schedule, :date
  json.url schedule_url(schedule, format: :json)
end
