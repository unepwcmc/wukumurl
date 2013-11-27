require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          begin
            bind_to_ldap
          rescue
            fail(:invalid_login)
          end
        end
      end

      def bind_to_ldap
        if ldap.bind
          user = User.where(email: email).first || User.create(user_data)
          return success!(user)
        else
          fail(:invalid_login)
        end
      end

      def ldap
        ldap = Net::LDAP.new
        ldap.host = "wcmc-dc-01.internal.wcmc"
        ldap.port = 389
        ldap.auth email, password

        ldap
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def user_data
        {:email => email, :password => password, :password_confirmation => password}
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
