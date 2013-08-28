%%% Websocket handler
-module (overseer_handler_ws).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
    overseer_cfg:read("commands.cfg"),
    {upgrade, protocol, cowboy_websocket}.

%% On init: reply to frontend with hostname and allowed requests
websocket_init(_TransportName, Req, _Opts) ->
    {ok, Hostname} = inet:gethostname(),
    Hello = list_to_binary(string:join([Hostname | overseer_cfg:keys()], "||")),
    overseer_cfg:set(<<"TIMER">>, none),
    self() ! {hello, Hello},
    {ok, Req, undefined_state}.

%% Handle all plain text messages received from frontend
websocket_handle({text, Msg}, Req, State) ->
    {Info, Delay} = overseer_cfg:key(Msg),
    % Stop data stream initiated by previous query (if exists)
    case overseer_cfg:key(<<"TIMER">>) of
        none   -> ok;
        _Timer -> erlang:cancel_timer(_Timer)
    end,
    erlang:start_timer(0, self(), {Info, Delay}),
    % Also send to frontend information about the command which is executed now
    BinInfo = list_to_binary(["$$" | Info]),
    {reply, {text, BinInfo}, Req, State};
websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

%% Process all the messages!
% Initiation
websocket_info({hello, Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};
% Main streams loop
websocket_info({timeout, _Ref, {Msg, Delay}}, Req, State) ->
    % Reply = list_to_binary(os:cmd(Msg)),
    {done, _Status, Reply} = erlsh:run(Msg),
    Timer = erlang:start_timer(Delay * 1000, self(), {Msg, Delay}),
    overseer_cfg:set(<<"TIMER">>, Timer),
    {reply, {text, Reply}, Req, State};
websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.
