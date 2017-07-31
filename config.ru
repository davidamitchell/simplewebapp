require 'rack/lobster'
require 'pg'

begin
    con = PG.connect :dbname => 'sampledb', :user => 'userUQ4', :password => 'RbB60VDdVgefxfCo', :host => 'postgresql'

    user = con.user
    db_name = con.db
    pswd = con.pass

    puts "User: #{user}"
    puts "Database name: #{db_name}"
    puts "Password: #{pswd}"
    puts ENV
    
    con.exec "create table if not exists accounts(id integer primary key, name varchar(100))"
    
    con.exec "create table if not exists ledger(id integer primary key
                                                , fromAccountId integer references accounts(id)
                                                , toAccountId integer references accounts(id)
                                                , amount integer
                                                , description varchar(100))"

end

map '/health' do
  health = proc do |env|
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/lobster' do
  run Rack::Lobster.new
end
