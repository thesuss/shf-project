class ChangeArchivedMembershipsToArchivedUserMemberships < ActiveRecord::Migration[5.2]
  def change
    rename_table 'archived_memberships', 'archived_user_memberships'
    add_reference :archived_user_memberships, :owner, polymorphic: true, default: User, index: { name: "archd_user_mships_index_owner_id_type" }
  end
end
