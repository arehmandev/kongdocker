return {
    no_consumer = true, -- this plugin will only be API-wide,
    fields = {
        header_jwt_mapping = { type = "array", required = "true" }
    },
    self_check = function(schema, plugin_t, dao, is_updating)
        -- perform any custom verification
        return true
    end
}
