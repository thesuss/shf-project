Given(/^the following membership packets have been sent:$/) do |table|
  table.hashes.each do | hash |

    user = User.find_by(email: hash['user_email'].downcase)
    user.date_membership_packet_sent = hash['date_sent']

    user.save

  end
end
