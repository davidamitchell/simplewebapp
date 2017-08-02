class Account < ActiveRecord::Base
  has_many :ledger
end
