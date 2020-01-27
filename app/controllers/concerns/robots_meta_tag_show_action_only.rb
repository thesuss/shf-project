#--------------------------
#
# @module RobotsMetaTagShowActionOnly
#
# @desc Responsibility: Only the 'show' action should have the robots nofollow, noindex tag
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/26/20
#
#--------------------------


module RobotsMetaTagShowActionOnly


  protected

  def action_should_have_robots_none_tag?(action_name = '')
    action_name != 'show'
  end

end
