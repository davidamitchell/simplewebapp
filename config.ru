require 'rack/lobster'
require 'pg'

def log(con, msg)
  con.exec "insert into logs(message) values(#{msg}) "
end

begin
    con = PG.connect :dbname => ENV['POSTGRESQL_DATABASE'], :host => ENV['POSTGRESQL_SERVICE_HOST'], :user => ENV['POSTGRESQL_USER'], :password => ENV['POSTGRESQL_PASSWORD']
                  #  :dbname => 'sampledb'
                  #  , :host => 'postgres'
                  #  , :user => 'userUQ4'
                  #  , :password => 'RbB60VDdVgefxfCo'

    user = con.user
    db_name = con.db
    pswd = con.pass

    puts "User: #{user}"
    puts "Database name: #{db_name}"
    puts "Password: #{pswd}"
    puts ENV

    con.exec "create table if not exists logs(id integer primary key, message varchar(100), created_at timestamp default now());"
    con.exec "create table if not exists accounts(id integer primary key, name varchar(100));"

    con.exec "create table if not exists ledger(id integer primary key
                                                , fromAccountId integer references accounts(id)
                                                , toAccountId integer references accounts(id)
                                                , amount integer
                                                , description varchar(100));"

    a = con.exec("select table_name from information_schema.tables where table_schema= 'public';")
    a.each do |r|
        puts r.to_s
    end

end

map '/health' do
  health = proc do |env|
    log(con, "health")
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/lobster' do
  log(con, "lobster")
  run Rack::Lobster.new
end

map '/log' do
    log = proc do |env|
        a = con.exec("select table_name from information_schema.tables where table_schema= 'public';")
        a.each do |r|
            puts r.to_s
        end
        a = con.exec("select message from logs order by created_at desc")
        a.each do |r|
            puts r.to_s
        end
        res = {}
        res['tables'] = a.map{|h| h['table_name']}
        res['logs'] = l.map{|h| h['message']}

        [200, { "Content-Type" => "application/json" }, [res.to_json] ]
    end
    log(con, "log")
    run log
end
