#--------------------------
#
# @class ArchivedCompanyMembership
#
# @desc Responsibility: create an archived company membership
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   5/22/22
#--------------------------

class ArchivedCompanyMembership < AbstractArchivedMembership

  def self.orig_attribs_for_belonged_to
    [:name, :email]
  end
end
