module AdminOnly
  #--------------------------
  #
  # @class MasterChecklistType
  #
  # @desc Responsibility: Specifies the type of master checklist so that admins can
  #   specify which Master checklists are, for example,
  #   "ethical guideline" checklists.  It is important for each Master Checklist have a
  #    named 'type' so that the system can show things like "all Ethical Guideline
  #    Master Checklists that have been agreed to by users in the past
  #   ( = UserChecklist) but have been superceded (are no longer in use)".
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date 2020-01-22
  #
  #--------------------------
  #
  #
  class MasterChecklistType < ApplicationRecord

    has_many :master_checklists


    validates_presence_of :name
    validates_uniqueness_of :name


    # TODO - Eventually get this from AppConfiguration info?
    MEMBER_GUIDELINES_LIST_TYPE = 'Medlemsåtagande'


    # --------------------------------------------------------------------------

    # TODO will later get this from AppConfiguration. Hardcoded for now
    def self.membership_guidelines_type
      find_by(name: MEMBER_GUIDELINES_LIST_TYPE)
    end


    # --------------------------------------------------------------------------


    def top_level_master_checklists
      master_checklists.top_level_checklists
    end

  end

end

