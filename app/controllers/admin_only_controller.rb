#--------------------------
#
# @class AdminOnlyController
#
# @desc Responsibility: Abstract class defining common behavior for all controllers that only Admins can use
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   1/26/20
#
#--------------------------


class AdminOnlyController < ApplicationController

  include RobotsMetaTagAllActions

  before_action :authorize_admin


  private


  def authorize_admin
    AdminPolicy.new(current_user).authorized?
  end

end
