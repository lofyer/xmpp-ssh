import xmpp

username = 'and'
passwd = 'mypassword'
to='lofyer@lofyer.org'
msg='hello :)'


client = xmpp.Client('lofyer.org')
client.connect(server=('lofyer.org',5222))
client.auth(username, passwd)
client.sendInitPresence()
message = xmpp.Message(to, msg)
message.setAttr('type', 'chat')
client.send(message)
