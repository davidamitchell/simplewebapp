require 'json'
require 'securerandom'

brokers = ["#{ENV['KAFKA_HOST']}:#{ENV['KAFKA_PORT']}"]
kafka = Kafka.new(seed_brokers: brokers)
producer = kafka.producer
topic = 'events'
uuid = ''

set :public_folder, 'static'

before do
  content_type :json
  uuid = SecureRandom.uuid
  # producer.produce(
  #     {
  #       eventtype: 'route_called',
  #       source: 'frontend',
  #       data: {
  #         method: request.request_method,
  #         url: request.url,
  #         params: request.params,
  #       },
  #       requestid: uuid
  #     }.to_json, topic: topic) unless request.path == '/health'
end

after do
  # producer.produce(
  #     {
  #       eventtype: 'route_responded',
  #       source: 'frontend',
  #       data: {
  #         status: response.status,
  #         body: response.body
  #       },
  #       requestid: uuid
  #     }.to_json, topic: topic) unless request.path == '/health'
  producer.deliver_messages
end

get '/' do
  redirect '/index.html'
end

get '/health' do
end

get '/balances' do
  a = Account.with_ledger.distinct
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']
  a = a.order(:created_at)
  accounts = a.map do |account|
    { account: account, balance: account.ledger.to_a.sum(&:amount) }
  end

  { balances: accounts }.to_json
end

get '/accounts' do
  a = Account.all
  a = a.by_owner(params['owner']) if params['owner']
  a = a.by_name(params['name']) if params['name']
  { accounts: a }.to_json
end

get '/accounts/:accountid' do
  puts "getting account id: #{params['accountid']}"
  a = Account.find(params['accountid'])
  { account: a }.to_json
end

post '/accounts' do
  puts "posting to accounts"
  request.body.rewind
  data = JSON.parse request.body.read
  a = Account.create( name: data['name'], owner: data['owner'], uid: uuid )
  producer.produce({eventtype: 'account_created', source: 'frontend', data: a, requestid: uuid}.to_json, topic: topic)
  { account: a }.to_json
end

get '/ledgers' do
  puts 'getting ledgers'
  l = Ledger.all
  { ledgers: l }.to_json
end

get '/ledgers/:ledgerid' do
  puts "getting ledger id: #{params['ledgerid']}"
  l = Ledger.find(params['ledgerid'])
  { ledger: l }.to_json
end

post '/ledgers' do
  puts 'posting to ledgers'
  request.body.rewind
  data = JSON.parse request.body.read
  l = Ledger.create( account_id: data['account_id'], amount: data['amount'], uid: uuid )
  producer.produce({eventtype: 'ledger_created', source: 'frontend', data: l, requestid: uuid}.to_json, topic: topic)
  { ledger: l }.to_json
end
