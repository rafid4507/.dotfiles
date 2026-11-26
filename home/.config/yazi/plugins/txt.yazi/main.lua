local M = {}

-- Preview .txt with Yazi's built-in code renderer.
-- Yazi calls this as a method: peek(self, job), so `function M:peek(job)`
-- is required. A plain `local function peek(job)` would receive the plugin
-- table instead of the real job and break ya.preview_code().
function M:peek(job)
	local err, bound = ya.preview_code(job)
	if bound then
		ya.emit("peek", { bound, only_if = job.file.url, upper_bound = true })
	elseif err and not err:find("cancelled", 1, true) then
		require("empty").msg(job, err)
	end
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end

	local step = math.floor(job.units * job.area.h / 10)
	step = step == 0 and ya.clamp(-1, job.units, 1) or step

	ya.emit("peek", {
		math.max(0, cx.active.preview.skip + step),
		only_if = job.file.url,
	})
end

return M
