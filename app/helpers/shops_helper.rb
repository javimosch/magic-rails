module ShopsHelper

  def chain_name(id)
    chains = {}
    chains['3'] = 'Ooshop'
    chains['1'] = 'Monoprix'
    chains['2'] = 'Auchan'
    chains['7'] = 'Intermarché'
    chains['8'] = 'Courses U'
    chains['5'] = 'Simply Market'
    chains['10'] = 'Auchan'
    chains['11'] = 'Carrefour'
    chains['4'] = 'Casino'
    chains['9'] = 'Casino Express'
    chains['12'] = 'Leclerc'
    chains['6'] = 'Amazon Food'
    chains['13'] = 'Chrono Drive'
    chains['14'] = 'Cora'
    chains['15'] = 'Lidl'

    unless chains[id].blank?
      return chains[id]
    else
      return 'Chaine inconnue'
    end
  end

  def get_shop(id)
    shop_url = "https://www.mastercourses.com/api2/stores/#{id}"
    shop = Rails.cache.fetch(shop_url, expires_in: 1.days) do
      HTTParty.get(shop_url, query: {
        mct: ENV['MASTERCOURSE_KEY']
      }).parsed_response
    end
    shop['name'] = chain_name(shop['chain_id'].to_s)
    return shop
  end
end
