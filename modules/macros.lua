-- Macros. Run at compile time.
addOption("m", function()
	addPreProcessor(function(code, infile)
		local alreadyprinted = false
		local newcode = code:gsub("%<%[%[(.-)%]%]%>", function(code)
			if not alreadyprinted then
				winfo("Running Macros in ".. infile .."... ")
				alreadyprinted = true
			end
			local fun, err = loadstring(code)
			if err then
				fatal("Macro failed: "..tostring(err))
			end
			return fun()
		end)
		if alreadyprinted then
			print("Done.")
		end
		return newcode
	end)
end, "Process Macros.")