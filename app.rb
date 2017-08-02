require 'json'

before do
  content_type :json
end

get '/' do
end

get '/balances' do
  puts 'getting balances'
  a = Account.with_ledger.distinct
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']

  a.map do |account|
    { account: account, balance: account.ledger.to_a.sum(&:amount) }
  end.to_json
end

get '/accounts' do
  puts 'getting accounts'
  a = Account.with_ledger
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']

  a.all.to_json
end

get '/accounts/:accountid' do
  puts "getting account id: #{params['accountid']}"
  Account.find(params['accountid']).to_json
end

post '/accounts' do
  puts "posting to accounts"
  request.body.rewind
  data = JSON.parse request.body.read
  a = Account.create( name: data['name'], owner: data['owner'] )
  a.to_json
end

get '/ledgers' do
  puts 'getting ledgers'
  Ledger.all.to_json
end

get '/ledgers/:ledgerid' do
  puts "getting ledger id: #{params['ledgerid']}"
  Ledger.find(params['ledgerid']).to_json
end

post '/ledgers' do
  puts 'posting to ledgers'
  request.body.rewind
  data = JSON.parse request.body.read
  a = Ledger.create( account_id: data['account_id'], amount: data['amount'] )
  a.to_json
end
