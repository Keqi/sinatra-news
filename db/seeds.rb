maciorn = User.create!(username: 'maciorn', password: 'secret')
jacek   = User.create!(username: 'jacek', password: 'secret')

board = Board.create!(title: "Famous sites")

gag   = Story.create!(user: maciorn, title: '9gag', url: "http://www.9gag.com")
kwejk = Story.create!(user: maciorn, title: 'kwejk', url: "http://www.kwejk.pl")
onet  = Story.create!(user: jacek, title: 'onet', url: "http://www.onet.pl")

Vote.create!(story: gag, user: maciorn, value: 1)
Vote.create!(story: gag, user: jacek, value: 1)
Vote.create!(story: kwejk, user: maciorn, value: 1)
Vote.create!(story: onet, user: maciorn, value: -1)
Vote.create!(story: onet, user: jacek, value: -1)

