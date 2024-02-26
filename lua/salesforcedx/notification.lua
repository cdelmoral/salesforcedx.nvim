local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local notification = {}

function notification:new(opts)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	self.message = opts.message
	self.level = vim.log.levels.INFO
	return o
end

function notification:start_progress()
	self.spinner_frames_index = 1
	self.in_progress = true
	self.id = vim.notify(self:get_formatted_message(), self.level, {
		title = "Salesforce DX",
		hide_from_history = true,
		icon = spinner_frames[self.spinner_frames_index],
	})
	self:update_spinner()
end

function notification:complete(opts)
	self.message = opts.message or self.message
	self.level = opts.level or self.message
	self.in_progress = false
end

function notification:update_spinner()
	local new_spinner_frames_index = (self.spinner_frames_index + 1) % #spinner_frames
	self.spinner_frames_index = new_spinner_frames_index
	self.id = vim.notify(self:get_formatted_message(), self.level, {
		title = "Salesforce DX",
		hide_from_history = true,
		icon = spinner_frames[new_spinner_frames_index],
		replace = self.id,
	})

	if self.in_progress then
		vim.defer_fn(function()
			self:update_spinner()
		end, 100)
	else
		local opts = {
			title = "Salesforce DX",
			icon = "",
			replace = self.id,
			timeout = 5000,
		}

		if self.level == vim.log.levels.ERROR then
			opts.icon = ""
		end

		vim.notify(self:get_formatted_message(), self.level, opts)
	end
end

function notification:get_formatted_message()
	return " " .. self.message
end

return notification
