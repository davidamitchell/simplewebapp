require 'json'

before do
  content_type :json
end

get '/' do
end

get '/balances' do
  puts 'getting balances'
  if params['owner']
    Account.where(owner: params['owner']).joins(:ledger).includes(:ledger).map do |account|
      { account: account, balance: account.ledger.to_a.sum(&:amount) }
    end
  else
    Account.joins(:ledger).includes(:ledger).map do |account|
      { account: account, balance: account.ledger.to_a.sum(&:amount) }
    end
  end.to_json
end

get '/accounts' do
  puts 'getting accounts'
  if params['owner']
    Account.where(owner: params['owner']).to_json
  else
    Account.all.to_json
  end
end

get '/accounts/:accountid' do
  puts "getting account id: #{params[:accountid]}"
  "getting account id: #{params[:accountid]}"
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
  puts "getting ledger id: #{params[:ledgerid]}"
  Ledger
end

post '/ledgers' do
  puts 'posting to ledgers'
  request.body.rewind
  data = JSON.parse request.body.read
  a = Ledger.create( account_id: data['account_id'], amount: data['amount'] )
  a.to_json
end
