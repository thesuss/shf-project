# frozen_string_literal: true

#--------------------------
#
# @module HasProofOfMembershipImage
#
# @desc Responsibility: maintains entry into a Rails cache for a proof of membership image
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   5/20/22
#
#--------------------------

module HasProofOfMembershipImage

  PROOF_OF_MEMBERSHIP_CACHE = 'proof-of-membership-image' # name of the cache for storing the proof of membership images

  # --------------------------------------------------------------------------------------------------

  def proof_of_membership_image
    cache.read(pom_image_cache_key)
  end

  def proof_of_membership_image=(image)
    cache.write(pom_image_cache_key, image)
  end

  # --------------------------------------------------------------------------------------------------

  private

  def clear_proof_of_membership_image_cache
    cache.delete(pom_image_cache_key)
  end

  # @return [String] string constructed from the class, id, and proof of membership cache string
  def pom_image_cache_key
    "#{self.class.name}_#{id}_cache_#{cache_name}"
  end

  def cache
    Rails.cache
  end

  def cache_name
    PROOF_OF_MEMBERSHIP_CACHE
  end
end
