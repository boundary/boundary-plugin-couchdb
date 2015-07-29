# Boundary CouchDB Plugin

The Boundary CouchDB plugin collects information on CouchDB. The information collected is what is returned by the [stats API](http://docs.couchdb.org/en/1.6.1/api/server/common.html#stats).

### Prerequisites

#### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

#### Boundary Meter v4.2 or later

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation). 
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

#### For Boundary Meter less than V4.0

|  Runtime | node.js | Python | Java |
|:---------|:-------:|:------:|:----:|
| Required |         |    +   |      |

- CouchDB [stats API](http://docs.couchdb.org/en/1.6.1/api/server/common.html#stats) to be accessible from the machine running the relay.
- [How to install Python?](https://help.boundary.com/hc/articles/202270132)

### Plugin Setup
Before the plugin will collect metrics, you must provide it with the URL used to access the CouchDB stats endpoint. By default, this is "http://127.0.0.1:5984/_stats", but it could be different if you have configured a different port.

### Plugin Configuration

#### For Boundary Meter v4.2
|Field Name     |Description                                                 |
|:--------------|:-----------------------------------------------------------|
|CouchDB Stats URL|The URL to CouchDB's stats API endpoint|
|User           |Password for the stats API endpoint.                                    |
|Password       |Password for the stats API endpoint.                                    |
|PollInterval   |Interval to query couchdb                                   |
|Source         |The source to display in the legend for the instance.       |

#### For Boundary Meter earlier than v4.2

|Field Name       |Description                            |
|:----------------|:--------------------------------------|
|CouchDB Stats URL|The URL to CouchDB's stats API endpoint|

### Metrics Collected

|Metric Name                         |Description                                        |
|:-----------------------------------|:--------------------------------------------------|
|CouchDB - HTTPD 201                 |Number of HTTP 201 Created responses               |
|CouchDB - HTTPD 200                 |Number of HTTP 200 OK responses                    |
|CouchDB - HTTPD 202                 |Number of HTTP 202 Accepted responses              |
|CouchDB - HTTPD 401                 |Number of HTTP 401 Unauthorized responses          |
|CouchDB - HTTPD 301                 |Number of HTTP 301 Moved Permanently responses     |
|CouchDB - HTTPD 304                 |Number of HTTP 304 Not Modified responses          |
|CouchDB - HTTPD 405                 |Number of HTTP 405 Method Not Allowed responses    |
|CouchDB - HTTPD 404                 |Number of HTTP 404 Not Found responses             |
|CouchDB - HTTPD 403                 |Number of HTTP 403 Forbidden responses             |
|CouchDB - HTTPD 500                 |Number of HTTP 500 Internal Server Error responses |
|CouchDB - HTTPD 412                 |Number of HTTP 412 Precondition Failed responses   |
|CouchDB - HTTPD 400                 |Number of HTTP 400 Bad Request responses           |
|CouchDB - HTTPD 409                 |Number of HTTP 409 Conflict responses              |
|CouchDB - Bulk Requests             |Number of bulk requests                            |
|CouchDB - Clients Requesting Changes|Number of clients for continuous changes           |
|CouchDB - View Reads                |Number of view reads                               |
|CouchDB - Requests                  |Number of HTTP requests                            |
|CouchDB - Temporary View Reads      |Number of temporary view reads                     |
|CouchDB - Open OS Files             |Number of file descriptors CouchDB has open        |
|CouchDB - Auth Cache Hits           |Number of authentication cache hits                |
|CouchDB - Database Reads            |Number of times a document was read from a database|
|CouchDB - Open Databases            |Number of open databases                           |
|CouchDB - Auth Cache Misses         |Number of authentication cache misses              |
|CouchDB - Database Writes           |Number of times a database was changed             |
|CouchDB - Request Time              |Length of a request inside CouchDB without MochiWeb|
|CouchDB - HEAD Requests             |Number of HTTP HEAD requests                       |
|CouchDB - GET Requests              |Number of HTTP GET requests                        |
|CouchDB - PUT Requests              |Number of HTTP PUT requests                        |
|CouchDB - POST Requests             |Number of HTTP POST requests                       |
|CouchDB - COPY Requests             |Number of HTTP COPY requests                       |
|CouchDB - DELETE Requests           |Number of HTTP DELETE requests                     |

### Dashboards

- CouchDB

### References

None
