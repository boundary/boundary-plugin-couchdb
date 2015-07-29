-- Copyright 2015 Boundary, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.-
--
-- @author Gabriel Nicolas Avellaneda <avellaneda.gabriel@gmail.com>
-- @copyright 2015 Boundary, Inc

local framework = require('framework')
local url = require('url')
local Plugin = framework.Plugin
local WebRequestDataSource = framework.WebRequestDataSource
local Accumulator = framework.Accumulator
local notEmpty = framework.string.notEmpty
local auth = framework.util.auth
local isHttpSuccess = framework.util.isHttpSuccess
local parseJson = framework.util.parseJson

local params = framework.params
params.stats_url = notEmpty(params.stats_url, "http://127.0.0.1:5984/_stats")

local options = url.parse(params.stats_url)
options.auth = auth(params.username, params.password)

local acc = Accumulator:new()
local ds = WebRequestDataSource:new(options)
local plugin = Plugin:new(params, ds)
function plugin:onParseValues(data, extra)
  if not isHttpSuccess(extra.status_code) then
    self:emitEvent('error', ('Http Response Status Code %d. Please check the CouchDB endpoint configuration.'):format(extra.status_code))
    return
  end
  local success, parsed = parseJson(data)
  if not success then
    self:emitEvent('error', 'Can not parse metrics. Please check the CouchDB endpoint configuration.')
    return
  end
  local httpd_status_codes = parsed.httpd_status_codes
  local httpd = parsed.httpd
  local couchdb = parsed.couchdb
  local httpd_request_methods = parsed.httpd_request_methods
  
  local metrics = {}
  metrics['COUCHDB_HTTPD_200'] = acc:accumulate('COUCHDB_HTTPD_200', httpd_status_codes['200'].current or 0)
  metrics['COUCHDB_HTTPD_201'] = acc:accumulate('COUCHDB_HTTPD_201', httpd_status_codes['201'].current or 0)
  metrics['COUCHDB_HTTPD_202'] = acc:accumulate('COUCHDB_HTTPD_202', httpd_status_codes['202'].current or 0)
  metrics['COUCHDB_HTTPD_301'] = acc:accumulate('COUCHDB_HTTPD_301', httpd_status_codes['301'].current or 0)
  metrics['COUCHDB_HTTPD_304'] = acc:accumulate('COUCHDB_HTTPD_304', httpd_status_codes['304'].current or 0)
  metrics['COUCHDB_HTTPD_400'] = acc:accumulate('COUCHDB_HTTPD_400', httpd_status_codes['400'].current or 0)
  metrics['COUCHDB_HTTPD_401'] = acc:accumulate('COUCHDB_HTTPD_401', httpd_status_codes['401'].current or 0)
  metrics['COUCHDB_HTTPD_403'] = acc:accumulate('COUCHDB_HTTPD_403', httpd_status_codes['403'].current or 0)
  metrics['COUCHDB_HTTPD_404'] = acc:accumulate('COUCHDB_HTTPD_404', httpd_status_codes['404'].current or 0)
  metrics['COUCHDB_HTTPD_405'] = acc:accumulate('COUCHDB_HTTPD_405', httpd_status_codes['405'].current or 0)
  metrics['COUCHDB_HTTPD_409'] = acc:accumulate('COUCHDB_HTTPD_409', httpd_status_codes['409'].current or 0)
  metrics['COUCHDB_HTTPD_412'] = acc:accumulate('COUCHDB_HTTPD_412', httpd_status_codes['412'].current or 0)
  metrics['COUCHDB_HTTPD_500'] = acc:accumulate('COUCHDB_HTTPD_500', httpd_status_codes['500'].current or 0)
  metrics['COUCHDB_HTTPD_BULK_REQUESTS'] = acc:accumulate('COUCHDB_HTTPD_BULK_REQUESTS', httpd.bulk_requests.current or 0)
  metrics['COUCHDB_CLIENTS_REQUESTING_CHANGES'] = acc:accumulate('COUCHDB_CLIENTS_REQUESTING_CHANGES', httpd.clients_requesting_changes.current or 0)
  metrics['COUCHDB_VIEW_READS'] = acc:accumulate('COUCHDB_VIEW_READS', httpd.view_reads.current or 0)
  metrics['COUCHDB_REQUESTS'] = acc:accumulate('COUCHDB_REQUESTS', httpd.requests.current or 0)
  metrics['COUCHDB_TEMPORARY_VIEW_READS'] = acc:accumulate('COUCHDB_TEMPORARY_VIEW_READS', httpd.temporary_view_reads.current or 0)
  metrics['COUCHDB_OPEN_OS_FILES'] = couchdb.open_os_files.current or 0
  metrics['COUCHDB_AUTH_CACHE_HITS'] = acc:accumulate('COUCHDB_AUTH_CACHE_HITS', couchdb.auth_cache_hits.current or 0)
  metrics['COUCHDB_DATABASE_READS'] = acc:accumulate('COUCHDB_DATABASE_READS', couchdb.database_reads.current or 0)
  metrics['COUCHDB_OPEN_DATABASES'] = couchdb.open_databases.current or 0
  metrics['COUCHDB_AUTH_CACHE_MISSES'] = acc:accumulate('COUCHDB_AUTH_CACHE_MISSES', couchdb.auth_cache_misses.current or 0)
  metrics['COUCHDB_DATABASE_WRITES'] = acc:accumulate('COUCHDB_DATABASE_WRITES', couchdb.database_writes.current or 0)
  metrics['COUCHDB_REQUEST_TIME'] = couchdb.request_time.current or 0
  metrics['COUCHDB_REQUEST_HEAD'] = acc:accumulate('COUCHDB_REQUEST_HEAD', httpd_request_methods.HEAD.current or 0)
  metrics['COUCHDB_REQUEST_GET'] = acc:accumulate('COUCHDB_REQUEST_GET', httpd_request_methods.GET.current or 0)
  metrics['COUCHDB_REQUEST_PUT'] = acc:accumulate('COUCHDB_REQUEST_PUT', httpd_request_methods.PUT.current or 0)
  metrics['COUCHDB_REQUEST_POST'] = acc:accumulate('COUCHDB_REQUEST_POST', httpd_request_methods.POST.current or 0)
  metrics['COUCHDB_REQUEST_COPY'] = acc:accumulate('COUCHDB_REQUEST_COPY', httpd_request_methods.COPY.current or 0)
  metrics['COUCHDB_REQUEST_DELETE'] = acc:accumulate('COUCHDB_REQUEST_DELETE', httpd_request_methods.DELETE.current or 0)

  return metrics
end

plugin:run()
