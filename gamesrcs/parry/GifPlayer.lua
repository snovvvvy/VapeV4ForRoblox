-- https://lua.expert/
local _ = script.Parent.Parent
local insert = table.insert
local remove = table.remove
local concat = table.concat
local RunService = game:GetService("RunService")
local Stepped = RunService.Stepped
local RenderStepped = RunService.RenderStepped
local v1 = if RunService:IsServer() then RunService.Heartbeat or RenderStepped else RenderStepped
local v2 = Instance.new
local v3 = next
local v4 = UDim2.new
local _2 = Rect.new
local v5 = Vector2.new
local floor = math.floor

local function f6(p1) --[[ Line: 242 | Upvalues: v5 (copy), floor (copy) ]]
	if p1.Previous then
		p1.Frames[p1.Previous].Visible = false
	end

	local v1 = p1.Frames[p1.Current]
	local v2 = p1.FrameData[p1.Current]
	local Resolution = v2.Resolution

	v1.ImageRectSize = Resolution
	v1.ImageRectOffset = Resolution * v5((p1.Position - 1) % v2.Cols, (floor((p1.Position - 1) / v2.Cols)))
	v1.Visible = true
	p1.Previous = p1.Current

	return p1
end

local wrap = coroutine.wrap
local v7 = tick

local function f8(p1, p2) --[[ Line: 257 | Upvalues: floor (copy), f6 (copy), v7 (copy), v1 (copy) ]]
	local v12 = false

	spawn(function() --[[ Line: 259 | Upvalues: p1 (copy), v12 (ref) ]]
		p1._pp.Event:Wait()
		v12 = true
	end)

	if not (p1.Loops > 0) then
		return
	end

	local v2 = false
	local count = 0

	while not v12 do
		local v3
		local TimePosition = p1.TimePosition
		local _d = p1._d
		local v4, v5, v6 = TimePosition, 0, 0

		for i = 1, #_d do
			if v4 < _d[i] then
				break
			end

			v6 = _d[i]
			v5 = i
		end

		p1.Current = v5 + 1

		local v72 = floor(p1.FrameData[v5 + 1].Count * (TimePosition - v6) / (p1._d[v5 + 1] - v6)) + 1

		if p1.Position == v72 then
			v3 = v5
		else
			local sum

			sum = 0
			v3 = v5

			for j = 1, v5 do
				sum = sum + p1.FrameData[j].Count
			end

			p1._fr:Fire(sum + v72)
		end

		if v72 == 1 and v2 then
			p1._ns:Fire(v3 + 1)
		end

		v2 = if v72 == 1 then false else true
		p1.Position = v72
		f6(p1)

		local v8 = v7()

		v1:Wait()

		local v9 = p1.TimePosition + (v7() - v8) * p2

		if v9 < 0 or p1.Duration < v9 then
			count = count + 1
			p1._l:Fire(count)
		end

		p1.TimePosition = v9 % p1.Duration

		if p1.Loops <= count then
			p1:Pause()
		end
	end
end

local t = {
	__index = {
		Play = function(p1, p2) --[[ Line: 302 | Upvalues: wrap (copy), f8 (copy) ]]
			if p1.Loops > 0 then
				p1:Pause()

				if p2 ~= 0 then
					p1.Playing = true
					wrap(f8)(p1, p2)
					p1._ap:Fire(p2)
				end
			end

			return p1
		end,
		Pause = function(p1) --[[ Line: 313 ]]
			if p1.Loops > 0 then
				p1.Playing = false
				p1._pp:Fire()
			end

			return p1
		end,
		Goto = function(p1, p2) --[[ Line: 320 | Upvalues: floor (copy), f6 (copy) ]]
			if p1.Loops > 0 then
				local v1 = p2 % p1.Duration
				local _d = p1._d

				v2 = v1
				v3 = 0
				v4 = 0

				for i = 1, #_d do
					if v2 < _d[i] then
						break
					end

					v4 = _d[i]
					v3 = i
				end

				p1.Current = v3 + 1
				p1.Position = floor(p1.FrameData[v3 + 1].Count * (v1 - v4) / (p1._d[v3 + 1] - v4)) + 1
				p1.TimePosition = v1
				f6(p1)
			end

			return p1
		end,
		Jump = function(p1, p2) --[[ Line: 331 | Upvalues: floor (copy), f6 (copy) ]]
			if p1.Loops > 0 then
				local sum = (p2 - 1) % p1.FrameCount + 1
				local sum2 = 0

				for i = 1, #p1.FrameData do
					local v1 = p1.FrameData[i]

					if sum <= v1.Count then
						sum2 = sum2 + sum * (1 / v1.FPS) - 1e-6

						break
					end

					sum2 = sum2 + v1.Count * (1 / v1.FPS)
					sum = sum - v1.Count
				end

				local _d = p1._d

				v2 = sum2
				v3 = 0
				v4 = 0

				for j = 1, #_d do
					if v2 < _d[j] then
						break
					end

					v4 = _d[j]
					v3 = j
				end

				p1.Current = v3 + 1
				p1.Position = floor(p1.FrameData[v3 + 1].Count * (sum2 - v4) / (p1._d[v3 + 1] - v4)) + 1
				p1.TimePosition = sum2
				f6(p1)
			end

			return p1
		end,
		Stop = function(p1) --[[ Line: 354 | Upvalues: f6 (copy) ]]
			p1.Playing = false
			p1._pp:Fire()
			p1._s:Fire()
			p1.Current = 1
			p1.Position = 1
			p1.TimePosition = 0
			f6(p1)

			return p1
		end,
		Destroy = function(p1) --[[ Line: 364 | Upvalues: remove (copy) ]]
			if p1.Playing then
				p1:Stop()
			end

			for i = #p1.Frames, 1, -1 do
				remove(p1.Frames, i):Destroy()
				remove(p1.FrameData, i)
			end

			p1.Loops = 0
			p1._ds:Fire()

			return p1
		end,
		SetParent = function(p1, p2) --[[ Line: 374 ]]
			if not (p1.Loops > 0) then
				return
			end

			for i = 1, #p1.Frames do
				p1.Frames[i].Parent = p2
			end
		end
	},
	__tostring = function() --[[ __tostring | Line: 391 ]]
		return "GIF"
	end
}

return function(p1) --[[ makeGIF | Line: 395 | Upvalues: v4 (copy), v5 (copy), insert (copy), v2 (copy), v3 (copy), f6 (copy), t (copy) ]]
	local t2 = {
		BackgroundTransparency = 1,
		Visible = false,
		Parent = p1.Screen,
		Size = v4(1, 0, 1, 0),
		Position = v4(0.5, 0, 0.5, 0),
		AnchorPoint = v5(0.5, 0.5)
	}
	local t3 = {}

	t3[1] = unpack(p1.Frames)

	local t4 = {}
	local sum = 0
	local sum2 = 0
	local t5 = {}

	for i = 1, #t3 do
		local v1 = t3[i]

		t2.Image = v1.Asset
		sum = sum + v1.Count
		sum2 = sum2 + v1.Count * 1 / v1.FPS
		insert(t5, (t5[i - 1] or 0) + v1.Count * 1 / v1.FPS)

		local v22 = v2("ImageLabel")

		for v32, v42 in v3, t2 do
			v22[v32] = v42
		end

		insert(t4, v22)
	end

	v2("BindableEvent")

	local v52 = v2("BindableEvent")
	local v6 = v2("BindableEvent")
	local v7 = v2("BindableEvent")
	local v8 = v2("BindableEvent")
	local v9 = v2("BindableEvent")
	local v10 = v2("BindableEvent")
	local v11 = v2("BindableEvent")

	return f6((setmetatable({
		Current = 1,
		Position = 1,
		TimePosition = 0,
		Playing = false,
		FrameData = t3,
		Frames = t4,
		Loops = p1.Loops,
		_d = t5,
		FrameCount = sum,
		Duration = sum2,
		Stopped = v7.Event,
		_s = v7,
		Paused = v10.Event,
		_pp = v10,
		Played = v52.Event,
		_ap = v52,
		FrameReached = v8.Event,
		_fr = v8,
		Loop = v9.Event,
		_l = v9,
		SheetReached = v6.Event,
		_ns = v6,
		Destroyed = v11.Event,
		_ds = v11
	}, t)))
end