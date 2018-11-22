Warden::Manager.after_authentication do |user, _auth, _opts|
  #user.update_membership_status
  #user&.check_member_status
  MembershipStatusUpdater.instance.check_requirements_and_act({user: user}) unless user.admin?
end

# https://github.com/hassox/warden/blob/
# fa24dcbf34022d85dce8db51dd11bbbe5a6fddcc/lib/warden/hooks.rb
