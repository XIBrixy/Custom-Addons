--[[
	Copyright © 2021, Tylas
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

		* Redistributions of source code must retain the above copyright
		  notice, this list of conditions and the following disclaimer.
		* Redistributions in binary form must reproduce the above copyright
		  notice, this list of conditions and the following disclaimer in the
		  documentation and/or other materials provided with the distribution.
		* Neither the name of XivParty nor the
		  names of its contributors may be used to endorse or promote products
		  derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL <your name> BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]

local utils = {}

-- log levels:
-- 0 ... finest
-- 1 ... fine
-- 2 ... info (default)
-- 3 ... warning
-- 4 ... error
utils.level = 3

function utils:createImage(imageInfo, scaleX, scaleY)
	if not scaleY then
		scaleY = scaleX
	end
	
	local size = utils:coord(imageInfo.size)
	local image = img:init(windower.addon_path .. imageInfo.path, size.x, size.y, scaleX, scaleY)
	
	if imageInfo.color then
		local color = utils:colorFromHex(imageInfo.color)
		image:color(color.r, color.g, color.b)
		image:alpha(color.a)
	end
	
	return image
end

function utils:createText(textInfo, right)
	if right == nil then
		right = false
	end

	local textSettings = {
		flags = {
			draggable = false,
			right = right
		}
	}
	
	local text = texts.new(textSettings)
	
	text:font(textInfo.font, 'Arial') -- Arial is the fallback font
	text:size(textInfo.size)
	text:bg_visible(false)
	
	local color = utils:colorFromHex(textInfo.color)
	local stroke = utils:colorFromHex(textInfo.stroke)
	
	text:color(color.r, color.g, color.b)
	text:alpha(color.a)
	text:stroke_color(stroke.r, stroke.g, stroke.b)
	text:stroke_alpha(stroke.a)
	text:stroke_width(textInfo.strokeWidth)
	
	return text
end

function utils:colorFromHex(hexString)
	local length = string.length(hexString)

	if not string.startswith(hexString, '#') or length < 7 or length > 9 then
		utils:log('Invalid hexadecimal color code. Expected format #RRGGBB or #RRGGBBAA', 4)
		return nil
	end
	
	local color = {}
	color.r = tonumber(string.slice(hexString, 2, 3), 16)
	color.g = tonumber(string.slice(hexString, 4, 5), 16)
	color.b = tonumber(string.slice(hexString, 6, 7), 16)
	if length > 7 then
		color.a = tonumber(string.slice(hexString, 8, 9), 16)
	else
		color.a = 255
	end
	
	return color
end

function utils:coord(coordList)
	local coord = {}
	
	if coordList then
		coord.x = coordList[1]
		coord.y = coordList[2]
	end
	
	if not coord.x then coord.x = 0 end
	if not coord.y then coord.y = 0 end
	
	return coord
end

function utils:round(num, numDecimalPlaces)
	if numDecimalPlaces and numDecimalPlaces > 0 then
		local mult = 10^numDecimalPlaces
		return math.floor(num * mult + 0.5) / mult
	end
	
	return math.floor(num + 0.5)
end

function utils:log(text, level)
	if level == nil then
		level = 2
	end	

	if self.level <= level and text then
		windower.add_to_chat(8, text) -- message type "8" can be filtered in-game as "call for help"
	end
end

function utils:toString(obj)
	if obj then
		return tostring(obj)
	end
	
	return '???'
end

function utils:logTable(t, depth)
	if not depth then
		depth = 0
	end

	local indent = ''
	for i = 0, depth, 1 do
		indent = indent .. ' '
	end

	if type(t) == 'table' then
		for key,value in pairs(t) do
			if type(value) == 'table' then
				windower.add_to_chat(8, indent .. key)
			elseif key ~= '_raw' and key ~= '_data' then
				windower.add_to_chat(8, indent .. key .. ' = ' .. tostring(value))
			end
			utils:logTable(value, depth + 3)
		end
	end
end

-- bitwise operations

function utils:bitAnd(a,b)
	local p,c=1,0
	while a>0 and b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>1 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c
end

function utils:bitOr(a,b)
	local p,c=1,0
	while a+b>0 do
		local ra,rb=a%2,b%2
		if ra+rb>0 then c=c+p end
		a,b,p=(a-ra)/2,(b-rb)/2,p*2
	end
	return c
end

function utils:bitNot(n)
	local p,c=1,0
	while n>0 do
		local r=n%2
		if r<1 then c=c+p end
		n,p=(n-r)/2,p*2
	end
	return c
end

return utils