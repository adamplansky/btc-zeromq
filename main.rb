require 'ffi-rzmq'

def error_check(rc)
  if ZMQ::Util.resultcode_ok?(rc)
    false
  else
    STDERR.puts "Operation failed, errno [#{ZMQ::Util.errno}] description [#{ZMQ::Util.error_string}]"
    caller(1).each { |callstack| STDERR.puts(callstack) }
    true
  end
end



ctx = ZMQ::Context.create(1)
STDERR.puts "Failed to create a Context" unless ctx
puts 'runing'
# sub_threads = []
# 2.times do |i|
#   sub_threads <<  Thread.new do
    sub_sock = ctx.socket(ZMQ::SUB)
    error_check(sub_sock.setsockopt(ZMQ::LINGER, 1))
    rc = sub_sock.setsockopt(ZMQ::SUBSCRIBE,'')
    error_check(rc)
    rc = sub_sock.connect("tcp://127.0.0.1:28335")
    error_check(rc)

    loop do
      # Since our messages are coming in multiple parts, we have to
      # check for that here
      puts '-------------------------'
      topic = ''
      rc = sub_sock.recv_string(topic)
      break if error_check(rc)
      # self.hashblock = ZMQSubscriber(socket, b"hashblock")
      # self.hashtx = ZMQSubscriber(socket, b"hashtx")
      # self.rawblock = ZMQSubscriber(socket, b"rawblock")
      # self.rawtx = ZMQSubscriber(socket, b"rawtx")

      if ['hashblock', 'hashtx', 'rawblock', 'rawtx'].include?(topic)
        # puts "Thread: #{i}: I received a message! The topic was '#{topic}'"
        puts "The topic was '#{topic}'"
        body = ''
        rc = sub_sock.recv_string(body) if sub_sock.more_parts?
        break if error_check(rc)
        puts "Message contained: #{body.unpack('H*')}"
      end


    end

    # always close a socket when we're done with it otherwise
    # the context termination will hang indefinitely
    error_check(sub_sock.close)
    # puts "Thread [#{i}] is exiting..."
  # end
  # end
  #
  # sub_threads.each {|t| t.join}
  # puts "Sub threads have terminated; terminating context"
  #
  # ctx.terminate
  # puts "terminated"
