# -*- lua -*-
propT = {
   lmod = {
      validT = { sticky = 1 },
      displayT = {
         sticky = { short = "(S)",  long = "(S)",   color = "red", doc = "Module is Sticky, requires --force to unload or purge",  },
      },
   },
   type_ = {
      validT = { compilers = 1, mpi = 2, development = 3, tools = 4, lang = 5, lib = 6 },
      displayT = {
         ["compilers"]     = { short = "(c)",  long = "(com)",   color = "blue", doc = "Tools for development", },
         ["mpi"]     = { short = "(m)",  long = "(mpi)",   color = "red", doc = "MPI implementations", },
         ["development"]     = { short = "(dev)",  long = "(development)",   color = "green", doc = "development libraries", },
         ["tools"]     = { short = "(t)",  long = "(tools)",   color = "yellow", doc = "utility tools", },
         ["lang"]     = { short = "(l)",  long = "(lang)",   color = "cyan", doc = "Languages", },
         ["lib"]     = { short = "(lib)",  long = "(libraries)",   color = "magenta", doc = "Libraries", },
      },
   },
}
