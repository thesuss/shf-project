if defined? Bullet
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true

  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'Company',
                association: :membership_applications

  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'MembershipApplication',
                association: :business_categories

  Bullet.add_whitelist type: :unused_eager_loading,
                 class_name: 'MembershipApplication',
                association: :membershipapplications_business_categories
end
