# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(email: 'admin@sverigeshundforetagare.se', password: 'hundapor', admin: true)

business_categories = ['Träning',
                       'Psykologi',
                       'Rehab', 'Butik', 'Trim', 'Friskvård', 'Dagis', 'Pensionat',
                       'Skola']
business_categories.each { |b_category| BusinessCategory.create(name: b_category)}
BusinessCategory.create(name: 'Sociala tjänstehundar', description: 'Terapi-, vård- & skolhund dvs hundar som jobbar tillsammans med sin förare/ägare inom vård, skola och omsorg.')
BusinessCategory.create(name: 'Civila tjänstehundar', description: 'Assistanshundar dvs hundar som jobbar åt sin ägare som service-, signal, diabetes, PH-hund mm')

