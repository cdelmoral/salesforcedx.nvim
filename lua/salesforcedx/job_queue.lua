local job_queue = {}

function job_queue:new()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	self.queue = {}
	self.results = {}
	self.on_complete_cb = nil
	return o
end

function job_queue:add(command, opts)
	table.insert(self.queue, { command = command, opts = opts })
end

function job_queue.run_jobs(jobs)
	local jobs_n = #jobs.queue

	if jobs_n > 0 then
		local job = jobs.queue[1]
		local opts = job.opts

		opts.callback = function(result)
			table.insert(jobs.results, result)
			table.remove(jobs.queue, 1)
			job_queue.run_jobs(jobs)
		end

		job.command(opts)
	else
		if jobs.on_complete ~= nil then
			jobs.on_complete_cb(jobs.results)
		end
	end
end

function job_queue:start()
	job_queue.run_jobs(self)
end

function job_queue:on_complete(callback)
	self.on_complete_cb = callback
end

return job_queue
