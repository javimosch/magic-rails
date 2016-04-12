# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create! email: 'contact@lafactoria.fr', password: 'azertyuiop', password_confirmation: 'azertyuiop', firstname: 'Jason', lastname: 'Fried', phone: '0658849653', share_phone: '0658849653'
AdminUser.create!(email: 'contact@lafactoria.fr', password: 'azertyuiop', password_confirmation: 'azertyuiop')