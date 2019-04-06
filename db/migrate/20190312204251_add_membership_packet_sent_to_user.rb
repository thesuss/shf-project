class AddMembershipPacketSentToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :date_membership_packet_sent, :timestamp, null: true,
               comment: 'When the user was sent a membership welcome packet'
  end
end
