function set_props(t)
   ------------------------------------------------------------
   -- table of properties for fullnames or sn

   local propT = {
      [ { "cuda", "gcc", "nvhpc", "intel", "intel-oneapi" } ] = { { name = "type_", value = "compilers" }, },
      [ { "openmpi", "mpich", "mpt" } ] = { { name = "type_", value = "mpi" }, },
      [ { "emacs", "matlab", "miniforge3", "pycharm", "vscode"  } ] = { { name = "type_", value = "development" }, },
      [ { "julia", "perl", "python", "R", "ruby"  } ] = { { name = "type_", value = "lang" }, },
      [ { "autconf", "automake", "bazel", "cmake", "curl"  } ] = { { name = "type_", value = "tools" }, },
   }

   for k,v in pairs(propT) do
     ------------------------------------------------------------
     -- Look for fullName first otherwise sn
     if (has_value(k,myModuleFullName()) or has_value(k,myModuleName())) then
        ----------------------------------------------------------
        -- Loop over value array and fill properties for this module.
        for i = 1,#v do
           local entry = v[i]
           add_property(entry.name, entry.value)
        end
     end
   end
end
