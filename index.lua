-- [boundary.com] CouchDB Lua Plugin
-- [author] Ivano Picco <ivano.picco@pianobit.com>

-- Requires.
local utils = require('utils')
local uv_native = require ('uv_native')
local string = require('string')
local timer = require('timer')
local ffi = require ('ffi')
local fs = require('fs')
local json = require('json')
local os = require ('os')
local tools = require ('tools')

local url  = require('url')
local http  = require('http')

local success, boundary = pcall(require,'boundary')
if (not success) then
  boundary = nil 
end

local isWindows = os.type() == 'win32'

-- portable gethostname syscall
ffi.cdef [[
  int gethostname (char *, int);
]]
function gethostname()
  local buf = ffi.new("uint8_t[?]", 256)
  if ( not isWindows ) then 
    ffi.C.gethostname(buf,256)
  else
    local clib = ffi.load('ws2_32')
    clib.gethostname(buf,256)
  end
  return ffi.string(buf)
end

-- Default parameters.
local source       = nil
local pollInterval = 10000
local port         = 5984
local host         = "127.0.0.1"
local couchDBStats = "/_stats"

-- Configuration.
local _parameters = (boundary and boundary.param) or json.parse(fs.readFileSync('param.json')) or {}

_parameters.pollInterval = 
  (_parameters.pollInterval and tonumber(_parameters.pollInterval)>0  and tonumber(_parameters.pollInterval)) or
  pollInterval;

_parameters.source =
  (type(_parameters.source) == 'string' and _parameters.source:gsub('%s+', '') ~= '' and _parameters.source ~= nil and _parameters.source) or
  gethostname()

_parameters.host = 
  (type(_parameters.host) == 'string' and _parameters.host:gsub('%s+', '') ~= '' and _parameters.host) or 
  host

_parameters.port = 
  (_parameters.port and tonumber(_parameters.port) and _parameters.port>0) and _parameters.port or 
  port

-- Back-trail.
local previousValues={}
local currentValues={}

-- Get difference between current and previous metric value.
function diffvalues(group,metric,current)
  if (current) then -- get the current value only
    return currentValues[group][metric].current or 0
  end

  local cur  = currentValues[group][metric].current or 0
  previousValues[group] = previousValues[group] or currentValues[group] or {}
  previousValues[group][metric] = previousValues[group][metric] or currentValues[group][metric] or {current = 0}
  local last = previousValues[group][metric].current or cur or 0
  previousValues[group][metric] = currentValues[group][metric]
  return  (tonumber(cur) - tonumber(last))
end

-- print results
function outputs()

  utils.print('COUCHDB_HTTPD_201', diffvalues('httpd_status_codes', '201'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_200', diffvalues('httpd_status_codes', '200'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_202', diffvalues('httpd_status_codes', '202'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_401', diffvalues('httpd_status_codes', '401'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_301', diffvalues('httpd_status_codes', '301'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_304', diffvalues('httpd_status_codes', '304'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_405', diffvalues('httpd_status_codes', '405'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_404', diffvalues('httpd_status_codes', '404'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_403', diffvalues('httpd_status_codes', '403'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_500', diffvalues('httpd_status_codes', '500'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_412', diffvalues('httpd_status_codes', '412'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_400', diffvalues('httpd_status_codes', '400'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_409', diffvalues('httpd_status_codes', '409'), _parameters.source) 
  utils.print('COUCHDB_HTTPD_BULK_REQUESTS', diffvalues('httpd', 'bulk_requests'), _parameters.source) 
  utils.print('COUCHDB_CLIENTS_REQUESTING_CHANGES', diffvalues('httpd', 'clients_requesting_changes'), _parameters.source) 
  utils.print('COUCHDB_VIEW_READS', diffvalues('httpd', 'view_reads'), _parameters.source) 
  utils.print('COUCHDB_REQUESTS', diffvalues('httpd', 'requests'), _parameters.source) 
  utils.print('COUCHDB_TEMPORARY_VIEW_READS', diffvalues('httpd', 'temporary_view_reads'), _parameters.source) 
  utils.print('COUCHDB_OPEN_OS_FILES', diffvalues('couchdb', 'open_os_files',true), _parameters.source) 
  utils.print('COUCHDB_AUTH_CACHE_HITS', diffvalues('couchdb', 'auth_cache_hits'), _parameters.source) 
  utils.print('COUCHDB_DATABASE_READS', diffvalues('couchdb', 'database_reads'), _parameters.source) 
  utils.print('COUCHDB_OPEN_DATABASES', diffvalues('couchdb', 'open_databases',true), _parameters.source) 
  utils.print('COUCHDB_AUTH_CACHE_MISSES', diffvalues('couchdb', 'auth_cache_misses'), _parameters.source) 
  utils.print('COUCHDB_DATABASE_WRITES', diffvalues('couchdb', 'database_writes'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_TIME', diffvalues('couchdb', 'request_time',true), _parameters.source) 
  utils.print('COUCHDB_REQUEST_HEAD', diffvalues('httpd_request_methods', 'HEAD'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_GET', diffvalues('httpd_request_methods', 'GET'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_PUT', diffvalues('httpd_request_methods', 'PUT'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_POST', diffvalues('httpd_request_methods', 'POST'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_COPY', diffvalues('httpd_request_methods', 'COPY'), _parameters.source) 
  utils.print('COUCHDB_REQUEST_DELETE', diffvalues('httpd_request_methods', 'DELETE'), _parameters.source) 

end

-- Client initialization
local httpClientOptions = {
  host = _parameters.host,
  port = _parameters.port,
  path = couchDBStats,
  headers = {
    ['Accept'] = 'application/json',
    ['Authorization'] = (_parameters.user and _parameters.password ) and 'Basic ' .. tools.base64(_parameters.user .. ':' .. _parameters.password) or nil
  }
}

-- Get current values.
function poll()

  local req = http.get( httpClientOptions, 
    function (res)
      if (res.status_code ~= 200) then
        return utils.debug("Error: Unexpected status code " .. res.status_code .. ", should be 200!")
      end

      local data = ''
      res:on('error', function(err)
        utils.debug('Error while receiving a response: ', err)  
      end)

      res:on('data', function(chunk)
        data = data .. chunk
      end)
      
      res:on('end', function()
        currentValues = json.parse(data)
        outputs()
      end)
         
    end)
        
  req:on('error', function(err)
      utils.debug('Error while sending a request: ', err)
  end)
       
  req:done()

end

-- Ready, go.
poll()
timer.setInterval(_parameters.pollInterval,poll)

