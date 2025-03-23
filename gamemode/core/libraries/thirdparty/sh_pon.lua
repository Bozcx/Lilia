﻿local pon = {}
_G.pon = pon
local type, count = type, table.Count
local tonumber = tonumber
local format = string.format
do
	local type, count = type, table.Count
	local tonumber = tonumber
	local format = string.format
	local encode = {}
	local tryCache
	local cacheSize = 0
	encode[ 'table' ] = function( self, tbl, output, cache )
		if cache[ tbl ] then
			output[ #output + 1 ] = format( '(%x)', cache[ tbl ] )
			return
		else
			cacheSize = cacheSize + 1
			cache[ tbl ] = cacheSize
		end

		local first = next( tbl, nil )
		local predictedNumeric = 1
		local lastKey = nil
		if first == 1 then
			output[ #output + 1 ] = '{'
			for k, v in next, tbl do
				if k == predictedNumeric then
					predictedNumeric = predictedNumeric + 1
					local tv = type( v )
					if tv == 'string' then
						local pid = cache[ v ]
						if pid then
							output[ #output + 1 ] = format( '(%x)', pid )
						else
							cacheSize = cacheSize + 1
							cache[ v ] = cacheSize
							self.string( self, v, output, cache )
						end
					else
						self[ tv ]( self, v, output, cache )
					end
				else
					break
				end
			end

			predictedNumeric = predictedNumeric - 1
		else
			predictedNumeric = nil
		end

		if predictedNumeric == nil then
			output[ #output + 1 ] = '['
		else
			output[ #output + 1 ] = '~'
		end

		for k, v in next, tbl, predictedNumeric do
			local tk, tv = type( k ), type( v )
			if tk == 'string' then
				local pid = cache[ k ]
				if pid then
					output[ #output + 1 ] = format( '(%x)', pid )
				else
					cacheSize = cacheSize + 1
					cache[ k ] = cacheSize
					self.string( self, k, output, cache )
				end
			else
				self[ tk ]( self, k, output, cache )
			end

			if tv == 'string' then
				local pid = cache[ v ]
				if pid then
					output[ #output + 1 ] = format( '(%x)', pid )
				else
					cacheSize = cacheSize + 1
					cache[ v ] = cacheSize
					self.string( self, v, output, cache )
				end
			else
				self[ tv ]( self, v, output, cache )
			end
		end

		output[ #output + 1 ] = '}'
	end

	local gsub = string.gsub
	encode[ 'string' ] = function( self, str, output )
		local estr, count = gsub( str, ";", "\\;" )
		if count == 0 then
			output[ #output + 1 ] = '\'' .. str .. ';'
		else
			output[ #output + 1 ] = '"' .. estr .. '";'
		end
	end

	encode[ 'number' ] = function( self, num, output )
		if num % 1 == 0 then
			if num < 0 then
				output[ #output + 1 ] = format( 'x%x;', -num )
			else
				output[ #output + 1 ] = format( 'X%x;', num )
			end
		else
			output[ #output + 1 ] = tonumber( num ) .. ';'
		end
	end

	encode[ 'boolean' ] = function( self, val, output ) output[ #output + 1 ] = val and 't' or 'f' end
	encode[ 'Vector' ] = function( self, val, output ) output[ #output + 1 ] = 'v' .. val.x .. ',' .. val.y .. ',' .. val.z .. ';' end
	encode[ 'Angle' ] = function( self, val, output ) output[ #output + 1 ] = 'a' .. val.p .. ',' .. val.y .. ',' .. val.r .. ';' end
	encode[ 'Entity' ] = function( self, val, output ) output[ #output + 1 ] = 'E' .. ( IsValid( val ) and val:EntIndex() .. ';' or '#' ) end
	encode[ 'Player' ] = encode[ 'Entity' ]
	encode[ 'Vehicle' ] = encode[ 'Entity' ]
	encode[ 'Weapon' ] = encode[ 'Entity' ]
	encode[ 'NPC' ] = encode[ 'Entity' ]
	encode[ 'NextBot' ] = encode[ 'Entity' ]
	encode[ 'PhysObj' ] = encode[ 'Entity' ]
	encode[ 'nil' ] = function() output[ #output + 1 ] = '?' end
	encode.__index = function( key )
		ErrorNoHalt( 'Type: ' .. key .. ' can not be encoded. Encoded as as pass-over value.' )
		return encode[ 'nil' ]
	end

	do
		local empty, concat = table.Empty, table.concat
		function pon.encode( tbl )
			local output = {}
			cacheSize = 0
			encode[ 'table' ]( encode, tbl, output, {} )
			local res = concat( output )
			return res
		end
	end
end

do
	local tonumber = tonumber
	local find, sub, gsub, Explode = string.find, string.sub, string.gsub, string.Explode
	local Vector, Angle, Entity = Vector, Angle, Entity
	local decode = {}
	decode[ '{' ] = function( self, index, str, cache )
		local cur = {}
		cache[ #cache + 1 ] = cur
		local k, v, tk, tv = 1, nil, nil, nil
		while true do
			tv = sub( str, index, index )
			if not tv or tv == '~' then
				index = index + 1
				break
			end

			if tv == '}' then return index + 1, cur end
			index = index + 1
			index, v = self[ tv ]( self, index, str, cache )
			cur[ k ] = v
			k = k + 1
		end

		while true do
			tk = sub( str, index, index )
			if not tk or tk == '}' then
				index = index + 1
				break
			end

			index = index + 1
			index, k = self[ tk ]( self, index, str, cache )
			tv = sub( str, index, index )
			index = index + 1
			index, v = self[ tv ]( self, index, str, cache )
			cur[ k ] = v
		end
		return index, cur
	end

	decode[ '[' ] = function( self, index, str, cache )
		local cur = {}
		cache[ #cache + 1 ] = cur
		local k, v, tk, tv = 1, nil, nil, nil
		while true do
			tk = sub( str, index, index )
			if not tk or tk == '}' then
				index = index + 1
				break
			end

			index = index + 1
			index, k = self[ tk ]( self, index, str, cache )
			if not k then continue end
			tv = sub( str, index, index )
			index = index + 1
			if not self[ tv ] then print( 'did not find type: ' .. tv ) end
			index, v = self[ tv ]( self, index, str, cache )
			cur[ k ] = v
		end
		return index, cur
	end

	decode[ '"' ] = function( self, index, str, cache )
		local finish = find( str, '";', index, true )
		local res = gsub( sub( str, index, finish - 1 ), '\\;', ';' )
		index = finish + 2
		cache[ #cache + 1 ] = res
		return index, res
	end

	decode[ '\'' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local res = sub( str, index, finish - 1 )
		index = finish + 1
		cache[ #cache + 1 ] = res
		return index, res
	end

	decode[ 'n' ] = function( self, index, str, cache )
		index = index - 1
		local finish = find( str, ';', index, true )
		local num = tonumber( sub( str, index, finish - 1 ) )
		index = finish + 1
		return index, num
	end

	decode[ '0' ] = decode[ 'n' ]
	decode[ '1' ] = decode[ 'n' ]
	decode[ '2' ] = decode[ 'n' ]
	decode[ '3' ] = decode[ 'n' ]
	decode[ '4' ] = decode[ 'n' ]
	decode[ '5' ] = decode[ 'n' ]
	decode[ '6' ] = decode[ 'n' ]
	decode[ '7' ] = decode[ 'n' ]
	decode[ '8' ] = decode[ 'n' ]
	decode[ '9' ] = decode[ 'n' ]
	decode[ '-' ] = decode[ 'n' ]
	decode[ 'X' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local num = tonumber( sub( str, index, finish - 1 ), 16 )
		index = finish + 1
		return index, num
	end

	decode[ 'x' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local num = -tonumber( sub( str, index, finish - 1 ), 16 )
		index = finish + 1
		return index, num
	end

	decode[ '(' ] = function( self, index, str, cache )
		local finish = find( str, ')', index, true )
		local num = tonumber( sub( str, index, finish - 1 ), 16 )
		index = finish + 1
		return index, cache[ num ]
	end

	decode[ 't' ] = function( self, index ) return index, true end
	decode[ 'f' ] = function( self, index ) return index, false end
	decode[ 'v' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local vecStr = sub( str, index, finish - 1 )
		index = finish + 1
		local segs = Explode( ',', vecStr, false )
		return index, Vector( tonumber( segs[ 1 ] ), tonumber( segs[ 2 ] ), tonumber( segs[ 3 ] ) )
	end

	decode[ 'a' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local angStr = sub( str, index, finish - 1 )
		index = finish + 1
		local segs = Explode( ',', angStr, false )
		return index, Angle( tonumber( segs[ 1 ] ), tonumber( segs[ 2 ] ), tonumber( segs[ 3 ] ) )
	end

	decode[ 'E' ] = function( self, index, str, cache )
		if str[ index ] == '#' then
			index = index + 1
			return index, NULL
		else
			local finish = find( str, ';', index, true )
			local num = tonumber( sub( str, index, finish - 1 ) )
			index = finish + 1
			return index, Entity( num )
		end
	end

	decode[ 'P' ] = function( self, index, str, cache )
		local finish = find( str, ';', index, true )
		local num = tonumber( sub( str, index, finish - 1 ) )
		index = finish + 1
		return index, Entity( num ) or NULL
	end

	decode[ '?' ] = function( self, index, str, cache ) return index + 1, nil end
	function pon.decode( data )
		local _, res = decode[ sub( data, 1, 1 ) ]( decode, 2, data, {} )
		return res
	end
end
