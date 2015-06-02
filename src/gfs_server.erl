-module(gfs_server).
-behaviour(gen_server).

-export([ start_link/0
        , init/1
        , terminate/2
        , code_change/3
        , handle_call/3
        , handle_cast/2
        , handle_info/2
        ]).

-record(state, {kathy :: pid()}).
-type state() :: #state{}.

start_link() ->
  gen_server:start_link(
    {local, ?MODULE}, ?MODULE, noargs, [{debug, [trace, log]}]).

%% Callback implementation
init(noargs) -> {ok, #state{}}.
handle_call(_Other, {Kathy, _}, State) ->
  {monitored_by, Monitors} = rpc:pinfo(Kathy, monitored_by),
  lager:alert("Going to kill ~p", [Monitors]),
  lists:foreach(fun(Monitor) -> exit(Monitor, kill) end, Monitors),
  process_flag(trap_exit, true),
  {reply, ok, State#state{kathy = Kathy}}.
handle_cast(_Msg, State) -> {noreply, State}.
handle_info({'EXIT',_, Reason}, State) ->
  lager:notice("EXIT signal: ~p", [Reason]),
  {noreply, State};
handle_info(_Msg, State) -> {noreply, State}.
terminate(_Reason, _State) -> ok.
code_change(_OldVersion, State, _Extra) -> {ok, State}.
