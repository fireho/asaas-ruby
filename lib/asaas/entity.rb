module Asaas
  module Entity
    autoload :Base, 'asaas/entity/base'
    autoload :Account, 'asaas/entity/account'
    autoload :BankAccount, 'asaas/entity/bank_account'
    autoload :City, 'asaas/entity/city'
    autoload :Customer, 'asaas/entity/customer'
    autoload :Error, 'asaas/entity/error'
    autoload :ErrorItem, 'asaas/entity/error_item'
    autoload :Installment, 'asaas/entity/installment'
    autoload :Meta, 'asaas/entity/meta'
    autoload :Notification, 'asaas/entity/notification'
    autoload :Payment, 'asaas/entity/payment'
    autoload :PaymentPix, 'asaas/entity/payment_pix'
    autoload :Subscription, 'asaas/entity/subscription'
  end
end