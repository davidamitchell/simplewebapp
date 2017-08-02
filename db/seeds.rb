account = Account.create({
  name: 'everyday',
  owner: 'Bob'
})

[100, -45, 250, -110, 25].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount
  })
end

account = Account.create({
  name: 'home loan',
  owner: 'Bob'
})

[-90000, 1000, 250, 1100, 25, -200].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount
  })
end

account = Account.create({
  name: 'everyday',
  owner: 'Sue'
})

[250, 1100, 250, -300, -90, 85, 10, -5].each do |amount|
  ledger = Ledger.create({
    account_id: account.id,
    amount: amount
  })
end
