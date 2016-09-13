class Wallet < ActiveRecord::Base

	belongs_to :user

	after_create :register

	private

	# Créé le portefeuille LemonWay.
	#
	# @!method register
	# @!scope class
	# @!visibility public
	def register


		proxy = URI(ENV['FIXIE_URL'])

		details = HTTParty.post(ENV['LEMONWAY_URL'] + '/GetWalletDetails',
			http_proxyaddr: proxy.host,
			http_proxyport: proxy.port,
			http_proxyuser: proxy.user,
			http_proxypass: proxy.password,
			headers: {
				'Content-Type' => 'application/json; charset=utf-8',
			},
			body: {
				wlLogin: ENV['LEMONWAY_LOGIN'],
				wlPass: ENV['LEMONWAY_PASS'],
				language: 'fr',
				version: '1.8',
				walletIp: '127.0.0.1',
				walletUa: 'ruby/rails',
				wallet: '',
				email: user.email
			}.to_json
		);

		if !details['d']['WALLET'].nil?
			cardsNb = details['d']['WALLET']['CARDS'].count
			if cardsNb > 0
				credit_card_display = details['d']['WALLET']['CARDS'][cardsNb - 1]['EXTRA']['NUM']
				lemonway_card_id = details['d']['WALLET']['CARDS'][cardsNb - 1]['ID']
			end
			self.update(lemonway_id: details['d']['WALLET']['ID'], credit_card_display: credit_card_display, lemonway_card_id: lemonway_card_id)
		else
			wallet = HTTParty.post(ENV['LEMONWAY_URL'] + '/RegisterWallet',
				http_proxyaddr: proxy.host,
				http_proxyport: proxy.port,
				http_proxyuser: proxy.user,
				http_proxypass: proxy.password,
				headers: {
					'Content-Type' => 'application/json; charset=utf-8',
				},
				body: {
					wlLogin: ENV['LEMONWAY_LOGIN'],
					wlPass: ENV['LEMONWAY_PASS'],
					language: 'fr',
					version: '1.8',
					walletIp: '127.0.0.1',
					walletUa: 'ruby/rails',
					wallet: created_at.to_time.to_i,
					clientMail: user.email,
					clientTitle: 'U',
					clientFirstName: user.firstname,
					clientLastName: user.lastname,
					street: '',
					postCode: '',
					city: '',
					ctry: 'FRA',
					birthdate: '',
					phoneNumber: user.phone,
					mobileNumber: user.phone,
					isCompany: '0',
					companyName: '',
					companyWebsite: '',
					companyDescription: '',
					companyIdentificationNumber: '',
					isDebtor: '0',
					nationality: 'FRA',
					birthcity: '',
					birthcountry: 'FRA',
					payerOrBeneficiary: '',
					isOneTimeCustomer: '0'
				}.to_json
		    );

			if wallet.code == 200

				if !wallet['d']['WALLET'].nil?
					self.update(lemonway_id: wallet['d']['WALLET']['ID'])
				elsif !wallet['d']['E'].nil?
					raise 'Wallet not found'
				end

			end

		end

	end

end
