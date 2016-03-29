class Wallet < ActiveRecord::Base

	belongs_to :user

	after_create :register

	private

	def register

		response = HTTParty.post(ENV['LEMONWAY_URL'] + '/RegisterWallet',
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
				wallet: id,
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

		if response.code == 200
			if !response['d']['WALLET'].nil?
				self.update(lemonway_id: response['d']['WALLET']['LWID'])
			elsif !response['d']['E'].nil?
				ap "LEMONWAY ERROR"
				ap response['d']['E']
			end
		end

	end

end
