#--------------------------
#
# @class ShfDeviseFailureApp
#
# @desc Responsibility: Redirect users to the login page if they try to
#   access a page that requires them to be logged in
#
# @see https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
# @see https://github.com/plataformatec/devise/wiki/Redirect-to-new-registration-(sign-up)-path-if-unauthenticated
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-25
#
#--------------------------


class ShfDeviseFailureApp < Devise::FailureApp


  def route(scope)
    # redirect only if they are a User,  not an Admin (or other type of Devise scope)
    scope.to_sym == :user ? :new_user_session_url : super
  end


  # Override respond to eliminate recall (see the Devise documentation pages for more info)
  def respond
    if http_auth?
      http_auth
    else
      flash.now[:alert] = i18n_message(:invalid) if is_flashing_format? && warden_options[:recall]
      redirect
    end
  end


  # This differs from super because it _adds_ the i18n_message to any existing
  # flash alerts instead of just assigning (and thus clobbering any flash
  # alerts that might already be there). This also uses flash.keep(:alert)
  # so that any alert message won't be lost if we redirect to a sign in page.
  # We must add to alerts if the email or password is missing from the sign_in
  # page.
  #
  def redirect
    store_location!
    if is_flashing_format?
      if flash[:timedout] && flash[:alert]
        flash.keep(:timedout)
        flash.keep(:alert)
      else
        unless flash[:alert] == i18n_message
          flash[:alert] =  "#{flash[:alert]}  #{i18n_message}"
        end
        flash.keep(:alert)
      end
    end
    redirect_to redirect_url
  end


end

