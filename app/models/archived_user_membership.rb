# Individual Membership that has been archived.  The information is saved only for auditing purposes,
#  but is not connected to any User or (archived) Payments so that privacy is maintained
#  (e.g. GDPR is followed).
#
class ArchivedUserMembership < AbstractArchivedMembership


  def self.orig_attribs_for_belonged_to
    [:first_name, :last_name, :email]
  end
end
