%%% Working with .cfg
-module (overseer_cfg).

-export ([read/1]).
-export ([key/1]).
-export ([keys/0]).
-export ([set/2]).

%% Read file to ETS
read(FileName) ->
    {ok, ConfigData} = file:consult(FileName),
    ets:new(id(), [set, named_table]),
    ets:insert(id(), ConfigData),
    ok.

%% Get item from ETS by key
key(Key) ->
    StrKey = binary_to_list(Key),
    [{_, Value}] = ets:lookup(id(), StrKey),
    Value.

%% Push item to ETS
set(Key, Value) ->
    ets:delete(id(), binary_to_list(Key)),
    ets:insert(id(), {binary_to_list(Key), Value}),
    ok.

%% Get all keys
keys() ->
    lists:sort([K || [{K, _}] <- ets:match(id(), '$1')]).

%% Generate unique ETS table ID
id() ->
    list_to_atom("config_" ++ erlang:pid_to_list(self())).
