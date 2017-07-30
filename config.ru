require 'rack/lobster'
require 'pg'

begin
    con = PG.connect :dbname => 'sampledb', :user => 'userUQ4', :password => 'RbB60VDdVgefxfCo'

    user = con.user
    db_name = con.db
    pswd = con.pass

    puts "User: #{user}"
    puts "Database name: #{db_name}"
    puts "Password: #{pswd}"
    puts ENV

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
