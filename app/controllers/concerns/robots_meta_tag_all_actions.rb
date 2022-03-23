#--------------------------
#
# @module RobotsMetaTagAllActions
#
# @desc Responsibility: All actions should have the robots nofollow, noindex tag
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/26/20
#
#--------------------------


module RobotsMetaTagAllActions


  protected

  # Always include the robots nofollow, noindex tag
  def action_should_have_robots_none_tag?(_action_name = '')
    true
  end


end
