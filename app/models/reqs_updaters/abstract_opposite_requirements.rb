#--------------------------
#
# @class AbstractOppositeRequirements
#
# @desc Responsibility: has the opposite (negated) requirements of an existing
#       Requirements class.
#       Ex:  if there is a Requirements class that represents the
#            'requirements for all the letters of the alphabet'
#            then an _opposite requirements class_ is one that does _not_
#            meet those requirements
#
#       All subclasses must implement the self.opposite_class method
#
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   2019-02-06
# @file abstract_opposite_requirements.rb
#
#--------------------------


class AbstractOppositeRequirements < AbstractRequirements

  # All subclasses must implement this method and return the class they are
  # the opposite of.
  #
  # Ex:  if a class is the opposite of the RequirementsForAllLettersOfTheAlphabet class
  #   def self.opposite_class
  #     RequirementsForAllLettersOfTheAlphabet
  #   end
  #
  def self.opposite_class
    raise NoMethodError, "Subclass must define the #{__method__} method and return the class they are the opposite of", caller
  end


  # This requires the same arguments as it's opposite class since
  # it sends those arguments to opposite_class.has_expected_arguments?(args)
  def self.has_expected_arguments?(args)
    opposite_class.has_expected_arguments?(args)
  end


  # This is always just the opposite of the opposite_class
  def self.requirements_met?(args)
    !opposite_class.requirements_met?(args)
  end

end # AbstractOppositeRequirements
