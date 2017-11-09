require 'ruby-kafka'
require 'json'
require 'active_record'
require 'require_all'
require 'erb'

require_all 'models/*.rb'

db_config = YAML::load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(db_config)

brokers = ["#{ENV['KAFKA_HOST']}:#{ENV['KAFKA_PORT']}"]
kafka = Kafka.new(seed_brokers: brokers)

# Consumers with the same group id will form a Consumer Group together.
consumer = kafka.consumer(group_id: "frontend")

# It's possible to subscribe to multiple topics by calling `subscribe`
# repeatedly.
consumer.subscribe("events", start_from_beginning: true)

# Stop the consumer when the SIGTERM signal is sent to the process.
# It's better to shut down gracefully than to kill the process.
trap("TERM") {
  puts 'shutting down the consumer'
  consumer.stop
}
trap("INT") {
  puts 'shutting down the consumer'
  consumer.stop
}

kafka.each_message(topic: "events") do |message|
    m = JSON.parse(message.value)
    # puts m
    if m['eventtype'] == 'account_created'
      data = m['data']
      a = Account.find_by_uid(m['requestid'])
      if a.nil?
        puts "creating new account from event"
        puts data
        puts
        a = Account.create( name: data['name'], owner: data['owner'], uid: m['requestid'] )
      end
    end
end
# This will loop indefinitely, yielding each message in turn.
# consumer.each_message do |message|
#   m = JSON.parse(message.value)
#   puts m
#   if m['eventtype'] == 'account_created' && m['source'] != 'frontend'
#     data = m['data']
#     a = Account.create( name: data['name'], owner: data['owner'], uid: m['requestid'] )
#   end
# end
