require("strict")

function dofile (filename)
	local f = assert(loadfile(filename))
	return f()
end

local lmod_package_path = os.getenv("LMOD_PACKAGE_PATH")
dofile(pathJoin(lmod_package_path,"SitePackage_properties.lua"))

local hook    = require("Hook")
local uname   = require("posix").uname
local cosmic  = require("Cosmic"):singleton()
local syshost = cosmic:value("LMOD_SYSHOST")

function has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

local s_msgT = {}

local function log_module_load(t)
	   -- the arg t is a table:
   --     t.modFullName:  the module full name: (i.e: gcc/4.7.2)
   --     t.fn:           The file name: (i.e /apps/modulefiles/Core/gcc/4.7.2.lua)
   --     t.mname:        The Module Name object.
   local debug_enabled = os.getenv("DEBUG_MODULES")
   local msg = string.format("user=%s module=%s path=%s host=%s time=%f",
                              os.getenv("USER"), t.modFullName, t.fn, uname("%n"),
                              epoch())
   s_msgT[t.modFullName] = msg
   if debug_enabled == "1" then
       io.stderr:write(msg, "\n")
   end
end

local function load_hook(t)
	log_module_load(t)
	set_props(t)
end

local function spider_hook(t)
	set_props(t)
end

local function report_loads()
   for k,msg in pairs(s_msgT) do
      lmod_system_execute("logger -t ModuleUsageTracking -p local0.info " .. msg)
   end
end

local function homeLabel(user)
   local currentUser = os.getenv("USER") or ""
   return "Modules from user: " .. user
end

local mapT =
{
   grouped = {
      ['/software/modules/rocky8/Other'] = "Manually Installed Software",
      ['/software/user/modules'] = "User Provided Software",
      ['/home/([^/]+)/']                 = homeLabel
   },
}
function avail_hook(t)
   local availStyle = masterTbl().availStyle
   local styleT     = mapT[availStyle]
   if (not availStyle or availStyle == "system" or styleT == nil) then
      return
   end
      for k,v in pairs(t) do
      for pat,label in pairs(styleT) do
         local user = k:match(pat)
         if user then
            if type(label) == "function" then
               t[k] = label(user)
            else
               t[k] = label
            end
            break
         end
      end
   end
end

hook.register("load", load_hook)
hook.register("avail",avail_hook)
hook.register("load_spider",spider_hook)
ExitHookA.register(report_loads)
