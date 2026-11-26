local M = {}

local function extractor_path()
	return (os.getenv("HOME") or "") .. "/.config/yazi/plugins/docx.yazi/extract.py"
end

local function split_lines(text)
	text = text:gsub("\n$", "")
	local lines = {}
	for line in (text .. "\n"):gmatch("([^\n]*)\n") do
		lines[#lines + 1] = line
	end
	return lines
end

-- Extract text from a DOCX with the small Python helper, then draw it in the
-- preview area. Yazi calls this as peek(self, job), so the colon form is
-- essential: a plain function would receive the plugin table, not the job.
function M:peek(job)
	local path = tostring(job.file.url.path)
	local output, err = Command("python3")
		:arg { extractor_path(), path }
		:output()

	local text
	if not output then
		text = "DOCX preview failed\n" .. tostring(err)
	elseif not output.status.success then
		local detail = output.stderr
		if not detail or detail == "" then
			detail = "extractor exited with a non-zero status"
		end
		text = "DOCX preview failed\n" .. detail
	else
		text = output.stdout
	end

	local all = split_lines(text)
	local skip = math.max(0, math.floor(job.skip or 0))
	local last = math.min(#all, skip + job.area.h + 10)

	local shown = {}
	for i = skip + 1, last do
		shown[#shown + 1] = all[i]
	end

	ya.preview_widget(job, ui.Text(table.concat(shown, "\n")):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if not h or h.url ~= job.file.url then
		return
	end

	local step = math.floor(job.units * job.area.h / 10)
	step = step == 0 and ya.clamp(-1, job.units, 1) or step

	ya.emit("peek", {
		math.max(0, (cx.active.preview.skip or 0) + step),
		only_if = job.file.url,
	})
end

return M
