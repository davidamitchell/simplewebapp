
require 'securerandom'

uuid = SecureRandom.uuid
account = Account.create({
  name: 'everyday',
  owner: 'Bob',
  uid: SecureRandom.uuid
})

[100, -45, 250, -110, 25].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount,
    uid: SecureRandom.uuid
  })
end

account = Account.create({
  name: 'home loan',
  owner: 'Bob',
  uid: SecureRandom.uuid
})

[-90000, 1000, 250, 1100, 25, -200].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount,
    uid: SecureRandom.uuid
  })
end

account = Account.create({
  name: 'everyday',
  owner: 'Sue',
  uid: SecureRandom.uuid
})

[250, 1100, 250, -300, -90, 85, 10, -5].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount,
    uid: SecureRandom.uuid
  })
end
