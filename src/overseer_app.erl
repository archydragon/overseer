%%% Main application module
-module(overseer_app).
-behaviour(application).

-export([start/2, stop/1]).

%% Nothing to write there about

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/ws", overseer_handler_ws, []},
            {"/static/[...]", cowboy_static, [
                {directory, {priv_dir, overseer, [<<"static">>]}},
                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            ]},
            {"/[...]", overseer_handler_index, []}
        ]}
    ]),
    {ok, _} = cowboy:start_http(http, 100, [{port, 6600}], [{env, [{dispatch, Dispatch}]}]),
    overseer_sup:start_link().

stop(_State) ->
    ok.
