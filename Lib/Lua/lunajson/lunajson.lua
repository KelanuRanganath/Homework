local newdecoder = require 'Lib/Lua/lunajson/decoder'
local newencoder = require 'Lib/Lua/lunajson/encoder'
local sax = require 'Lib/Lua/lunajson/sax'
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
	newparser = sax.newparser,
	newfileparser = sax.newfileparser,
}
