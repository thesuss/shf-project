# frozen_string_literal: true

class ArchivedMembershipError < StandardError; end


class AlreadyExistsError < ArchivedMembershipError; end


# ---------------------------------------------------------------------------------------------------------------
#
# @class AbstractArchivedMembership
#
# @responsibility: abstract parent class for all archived memberships
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   5/22/22
# ---------------------------------------------------------------------------------------------------------------
#
class AbstractArchivedMembership < ApplicationRecord
  self.abstract_class = true

  BELONGED_TO_PREFIX = 'belonged_to_'
  MEMBERSHIP_ATTRIBS = [:member_number, :first_day, :last_day, :notes]

  EXCLUDED_ATTRIBS_FOR_MATCHING = [:id, :notes, :created_at, :updated_at]
  # ================================================================================================

  # Create a new ArchivedUserMembership only if one does not already exist for the membership
  # If one already exists, raise an error
  #
  # @return [nil | ArchiveMembership] - return nil if nothing is created,
  #   else return the created ArchiveMembership
  def self.create_from(membership)
    raise ArgumentError 'The membership cannot be nil when creating an Archived Membership from it.' if membership.nil?

    verify_none_already_exists(membership) # Will raise an error if one already exists

    create!(attribs_from(membership))
  end

  # @param [AbstractMembership] membership - the entire list of attribs for an rchived membership.
  # @return [True, False] does an archived membership already exist when we compare only the meaningful attributes?
  def self.verify_none_already_exists(membership)
    attribs = attribs_from(membership)
    attribs_to_compare = self.new.attributes.keys.map(&:to_sym) - excluded_attribs_for_matching
    compare_with_values = {}
    attribs_to_compare.each do |attrib|
      compare_with_values[attrib] = attribs[attrib]
    end
    found_archived = find_by(compare_with_values)
    if found_archived
      raise(AlreadyExistsError, "#{self} (id: #{found_archived.id}) already exists for #{membership.inspect}")
    end
  end

  # @return [Hash]
  def self.attribs_from(membership)
    attribs = {}
    attribs.merge!(assign_membership_attribs(membership))
    attribs[:owner_id] = membership.owner.id
    attribs[:owner_type] = membership.owner.class.name
    attribs.merge!(assign_belonged_to_attribs(membership.owner))
    attribs.merge!(assign_specific_attribs(membership))
    attribs
  end

  # @param [User,Company]
  # @return [Hash]
  def self.assign_belonged_to_attribs(owner)
    assigned_attribs = {}
    orig_attribs_for_belonged_to.each do |orig_membership_attrib|
      belonged_to_attrib = "#{BELONGED_TO_PREFIX}#{orig_membership_attrib}".to_sym
      assigned_attribs[belonged_to_attrib] = owner[orig_membership_attrib]
    end
    assigned_attribs
  end

  def self.assign_membership_attribs(membership)
    assigned_attribs = {}
    membership_attribs.each do |membership_attrib|
      assigned_attribs[membership_attrib] = membership[membership_attrib]
    end
    assigned_attribs
  end

  # @param [AbstractMembership]
  # @return [Hash] other attribute names and their values
  def self.assign_specific_attribs(_membership)
    # subclasses can do whatever they need to do here
    {}
  end

  # Subclasses should list the attributes from the (original) Membership that they will copy and prefix with "belonged_to"
  def self.orig_attribs_for_belonged_to
    []
  end

  def self.membership_attribs
    MEMBERSHIP_ATTRIBS
  end

  def self.excluded_attribs_for_matching
    EXCLUDED_ATTRIBS_FOR_MATCHING
  end

  def self.belonged_to_attribs
    orig_attribs_for_belonged_to.map { |attrib| "#{BELONGED_TO_PREFIX}#{attrib}".to_sym }
  end
end
