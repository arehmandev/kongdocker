local cjson = require "cjson"
local helpers = require "spec.helpers"

describe("Plugin: unpacker", function ()
    local proxy_client, admin_client

    setup(function()
        assert(helpers.start_kong())
        proxy_client = helpers.proxy_client()
        admin_client = helpers.admin_client()

        local api1 = assert(helpers.dao.apis:insert {name = "tests-jwt1", request_host = "jwt.com", upstream_url = "http://mockbin.com"})

        assert(helpers.dao.plugins:insert {name = "unpacker", config = {header_jwt_mapping = {"X-Header-Test=testClaim"}}, api_id = api1.id})
    end)

    teardown(function ()
        if proxy_client then proxy_client:close() end
        if admin_client then admin_client:close() end
        helpers.stop_kong()
    end)

    it("Sets the correct headers based on configuration", function ()
        local res = assert(proxy_client:send {
            method = "GET",
            path = "/request",
            headers = {
                ["jwt"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsInRlc3RDbGFpbSI6InRlc3RWYWx1ZSJ9.LCFiT8MWKS238f2rQESFmImoJ4ez02XG_tXl8nBPNf8",
                ["Host"] = "jwt.com"
            }
        })

        local body = cjson.decode(assert.res_status(200, res))
        assert.equal("testValue", body.headers["x-header-test"])
    end)
end)