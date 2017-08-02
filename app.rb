require 'json'
require 'securerandom'


kafka = Kafka.new(seed_brokers: ["#{ENV['KAFKA_HOST']}:#{ENV['KAFKA_PORT']}"])
producer = kafka.producer
topic = 'events'
uuid = ''


before do
  uuid = SecureRandom.uuid
  content_type :json

  producer.produce(
      {
        eventtype: 'route_called',
        data: {
          method: request.request_method,
          url: request.url,
          params: request.params,
        },
        requestid: uuid
      }.to_json, topic: "events")
end

after do

  producer.produce(
      {
        eventtype: 'route_responded',
        data: {
          status: response.status,
          body: response.body
        },
        requestid: uuid
      }.to_json, topic: "events")

  producer.deliver_messages
end

get '/' do
end

get '/balances' do
  a = Account.with_ledger.distinct
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']

  r = a.map do |account|
    { account: account, balance: account.ledger.to_a.sum(&:amount) }
  end.to_json

  producer.produce({eventtype: 'balances_returned', data: r, requestid: uuid}.to_json, topic: "events")
  return r
end

get '/accounts' do
  a = Account.with_ledger
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']
  r = a.all.to_json
  producer.produce({eventtype: 'accounts_retrieved', data: r, requestid: uuid}.to_json, topic: "events")
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
  producer.produce({eventtype: 'account_created', data: a, requestid: uuid}.to_json, topic: "events")
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
