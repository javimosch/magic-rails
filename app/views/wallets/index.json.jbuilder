json.array!(@wallets) do |wallet|
  json.extract! wallet, :id, :user_id, :lemonway_id, :lemonway_card_id, :credit_card_display
  json.url wallet_url(wallet, format: :json)
end
