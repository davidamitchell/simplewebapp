require 'rack/lobster'
require 'pg'

class Logger
  def log(con, msg)
    con.exec "insert into logs(message) values('#{msg}') "
  end
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

    con.exec "create table if not exists logs(id bigserial primary key, message varchar(100), created_at timestamp default now());"
    con.exec "create table if not exists accounts(id bigserial primary key, name varchar(100));"

    con.exec "create table if not exists ledger(id bigserial primary key
                                                , fromAccountId integer references accounts(id)
                                                , toAccountId integer references accounts(id)
                                                , amount integer
                                                , description varchar(100));"

    a = con.exec("select table_name from information_schema.tables where table_schema= 'public';")
    a.each do |r|
        puts r.to_s
    end

    logger = Logger.new

end

map '/health' do
  health = proc do |env|
    logger.log(con, "health")
    [200, { "Content-Type" => "text/html" }, ["1"]]
  end
  run health
end

map '/lobster' do
  logger.log(con, "lobster")
  run Rack::Lobster.new
end

map '/log' do
    log_proc = proc do |env|
        a = con.exec("select table_name from information_schema.tables where table_schema= 'public';")
        a.each do |r|
            puts r.to_s
        end
        l = con.exec("select message, created_at from logs order by created_at desc")
        l.each do |r|
            puts r.to_s
        end
        res = {}
        res['tables'] = a.map{|h| h['table_name']}
        res['logs'] = l.map{|h| "#{h['message']} --xxx #{h['created_at']}" }

        logger.log(con, "log")
        [200, { "Content-Type" => "application/json" }, [res.to_json] ]
    end
    run log_proc
end
