class Account < ActiveRecord::Base
  has_many :ledger
  scope :by_owner, -> owner { where('lower(owner) = lower(?)', owner) }
  scope :by_name, -> name { where('lower(name) = lower(?)', name) }
  # scope :with_ledger, -> { joins(:ledger).includes(:ledger) }
  scope :with_ledger, -> { joins('left join ledgers l on l.account_id = accounts.id').includes(:ledger) }
end
