require 'json'

kafka = Kafka.new(seed_brokers: ['localhost:9092', 'localhost:9093', 'localhost:9094'])
producer = kafka.producer
topic = 'events'

before do
  content_type :json
end

after do
  producer.deliver_messages
end

get '/' do
end

get '/balances' do
  puts 'getting balances'
  producer.produce({eventtype: 'route_called', data: {route: 'balances', params: params}}.to_json, topic: "events")

  a = Account.with_ledger.distinct
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']

  r = a.map do |account|
    { account: account, balance: account.ledger.to_a.sum(&:amount) }
  end.to_json

  producer.produce({eventtype: 'balances_returned', data: r}.to_json, topic: "events")
  return r
end

get '/accounts' do
  puts 'getting accounts'
  producer.produce({eventtype: 'route_called', data: {route: 'accounts', params: params}}.to_json, topic: "events")

  a = Account.with_ledger
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']
  r = a.all.to_json
  producer.produce({eventtype: 'accounts_retrieved', data: r}.to_json, topic: "events")
  return r
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
  producer.produce({eventtype: 'account_created', data: a.to_json}.to_json, topic: "events")
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
