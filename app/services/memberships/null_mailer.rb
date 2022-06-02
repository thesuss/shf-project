# froze_string_literal: true

module Memberships
  #--------------------------
  #
  # @class NullMailer
  #
  # @desc Responsibility: Stand in for mailer classes but never sends any mail.
  #   _(This is a Null Object design pattern)_
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2022-05-21
  #
  #--------------------------

  class NullMailer
    def self.no_mail_sent(*); end
  end
end
