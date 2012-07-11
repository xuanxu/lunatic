local mime = require('mime')
local http = require('http')
local url  = require('url')
local fs   = require('fs')
local path = require('path')
local Response = require('http').Response

function Response:destroy()
  if self.socket then
    return self.socket.destroy()
  end
end

function Response:sendfile(status, filepath)
  fs.stat(filepath, function(err, st)
    self:writeHead(status, {
      ["Content-Type"] = mime.getType(filepath),
      ["Content-Length"] = st.size
    })
    fs.createReadStream(filepath):pipe(self)
  end)
end

local root = '.'

http.createServer(function(req, res)
  req.uri = url.parse(req.url)
  local filepath = path.normalize(root .. req.uri.pathname)

  fs.stat(filepath, function (err, stat)
    if err then
      if err.code == "ENOENT" or not stat.is_file then
        return res:sendfile(404, root .. '/404.html')
      end
      return res:sendfile(500, root .. '/500.html')
    end
    return res:sendfile(200, filepath)
  end)
end):listen(7373)

print("Lunatic listening at http://localhost:" .. "7373/")
