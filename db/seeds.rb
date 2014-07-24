if Rails.env == 'development'
  User.create(
    email: 'dev@wcmc.io',
    password: 'password',
    password_confirmation: 'password'
  )
end
