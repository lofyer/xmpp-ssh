#!/usr/bin/env ruby
 
# Jabber-SH — SH console via XMPP/Jabber (GTalk)
#
# Jabber-SH allows you to administrate a remote computer via a command line 
# through a Jabber client. It’s like SSH via GoogleTalk! :)
# This is just a hack but it might be usefull sometime to run basic commands
# on a machine that is not accessible via ssh.
#
# Philippe Creux. pcreux/AT/gmail/DOT/com
 
# Jabber-SH connects to Jabber using the BOT_LOGIN and BOT_PASSWORD details.
BOT_LOGIN         = "admin@lofyer.org"
BOT_PASSWORD      = "adminpassword"
 
# Jabber-SH answers some random epigram via 'fortune' to any message sent to him.
# The user CLIENT_LOGIN logs into the console by sending the CLIENT_PASSPHRASE.
CLIENT_LOGIN      = "lofyer@lofyer.org"
CLIENT_PASSPHRASE = "secreteword"
 
require 'rubygems'
require 'xmpp4r-simple'
require 'session'
 
puts "Connecting"
if messenger = Jabber::Simple.new(BOT_LOGIN, BOT_PASSWORD)
  puts "Connected"
else
  puts "Ooops - Can't connect"
end
 
@sh = nil
 
while true
  messenger.received_messages do |msg|  
    puts "Received #{msg.body} from #{msg.from}"
    begin
    if msg && msg.from.to_s.include?(CLIENT_LOGIN)
      if msg.body == CLIENT_PASSPHRASE
        if @sh == nil
          @sh = Session::new 
          message = "Now logged in!"
        else
          @sh.close && @sh = nil
          message = "Logged out..."
        end
        messenger.deliver(msg.from, message)
      else
        if @sh
          stdout, stderr = @sh.execute(msg.body) if msg.body
          messenger.deliver(msg.from, "\n" + stdout.chomp) unless stdout.empty?
          messenger.deliver(msg.from, "\n" + stderr.chomp) unless stderr.empty?
          messenger.deliver(msg.from, @sh.execute('pwd')[0].chomp + "$>")
        else
          messenger.deliver(msg.from, 'I am online.')
        end
      end
    end
    rescue
      messenger.deliver(msg.from, 'I got an error. Now please re-enter your password twice to logout-login.')
    end
  end  
  sleep 1  
end
