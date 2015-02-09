-- Macros. Run at compile time.
addOption("m", function()
	addPreProcessor(function(inputcode, infile)
		local alreadyprinted = false
		local newcode = inputcode:gsub("%<%[%[(.-)%]%]%>", function(code)
			if code and infile then
				if not alreadyprinted then
					winfo("Running Macros in ".. infile .."... ")
					alreadyprinted = true
				end
				local fun, err = loadstring(code)
				if err then
					fatal("Macro failed: "..tostring(err))
				end
				local succ, ret = pcall(fun)
				if succ then
					return tostring(ret)
				else
					fatal("Macro failed to execute: "..tostring(ret))
				end
			end
		end)
		if alreadyprinted then
			print("Done.")
		end
		return newcode
	end)
end, "Process Macros.")