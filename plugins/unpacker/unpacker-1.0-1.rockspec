package = "unpacker"
version = "1.0-1"
source = {
  url = "..."
}
description = {
  summary = "A Kong plugin.",
  license = "MIT/X11"
}
dependencies = {
  "lua ~> 5.1"
  -- If you depend on other rocks, add them here
}
build = {
  type = "builtin",
  modules = {
    ["kong.plugins.unpacker.handler"] = "./handler.lua",
    ["kong.plugins.unpacker.schema"] = "./schema.lua",
  }
}
