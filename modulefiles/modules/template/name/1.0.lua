-- local variables
local name = myModuleName()
local version = myModuleVersion()
-- If you your software is installed in different directory format other than /software/name/version then use `dir_version`
-- local dir_version = name .. '-' .. version
local root = pathJoin("/software", name, version)

local description = "<Add Software Description>"
local url = "<Add URL>"

if not isDir(root) then
    LmodError("Module directory does not exist: " .. root)
end

-- Module metadata
whatis("Name: " .. name)
whatis("Version: " .. version)
whatis("Description: " .. description)
whatis("URL: " .. url)

-- Help message
help([[
This module loads ]] .. name .. [[ version ]] .. version .. [[.

Description: ]] .. description .. [[

Usage: Run `<command> --help` for more information.

Website: ]] .. url .. [[

For support, please submit a ticket at <SITE>
]])

-- Dependencies and conflicts
-- depends_on("gcc/9.3", "openmpi/4.1") -- Uncomment and list required modules
-- prereq("gcc/9.3") -- Uncomment for prerequisites
-- conflict(name) -- Prevent loading multiple versions
-- family("software") -- Optional: group related modules

-- Environment Set
--setenv("SOFTWARE_ROOT", root)


-- Path settings
if isDir(pathJoin(root, "bin")) then
    prepend_path("PATH", pathJoin(root, "bin"))
end
if isDir(pathJoin(root, "lib64")) then
    prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib64"))
    prepend_path("LIBRARY_PATH", pathJoin(root, "lib64"))
elseif isDir(pathJoin(root, "lib")) then
    prepend_path("LD_LIBRARY_PATH", pathJoin(root, "lib"))
    prepend_path("LIBRARY_PATH", pathJoin(root, "lib"))
end
if isDir(pathJoin(root, "include")) then
    prepend_path("CPATH", pathJoin(root, "include"))
end
if isDir(pathJoin(root, "share/man")) then
    prepend_path("MANPATH", pathJoin(root, "share/man"))
end
if isDir(pathJoin(root, "lib/pkgconfig")) then
    prepend_path("PKG_CONFIG_PATH", pathJoin(root, "lib/pkgconfig"))
end

-- Testing and Debugging
if mode() == "load" then
    io.stderr:write("Loading " .. name .. "/" .. version .. "\n")
end

