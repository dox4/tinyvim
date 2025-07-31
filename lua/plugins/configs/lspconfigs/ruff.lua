return {
    on_attach = function(client, _)
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
    end,
    init_options = {
        settings = {
            format = {
                args = {
                    "--line-length",
                    "120",
                },
            },
            args = {},
        },
    },
}
