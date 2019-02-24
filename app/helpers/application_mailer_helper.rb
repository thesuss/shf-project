module ApplicationMailerHelper

  def membership_email_addr
    ENV['SHF_REPLY_TO_EMAIL']
  end


  # The link and text to the login page
  # Uses _blank so that it will open in a new browser window.
  #
  def login_url_link
    link_to(t('mailers.login_here'), new_user_session_url,  target: '_blank', rel: 'nofollow')
  end
end

