-module(gfs_server).
-behaviour(gen_server).

-export([ start_link/0
        , token/1
        , init/1
        , terminate/2
        , code_change/3
        , handle_call/3
        , handle_cast/2
        , handle_info/2
        ]).

-record(state, {kathy :: pid(), token :: term()}).
-type state() :: #state{}.

start_link() ->
  gen_server:start_link(
    {local, ?MODULE}, ?MODULE, noargs, [{debug, [trace, log]}]).

token(Token) -> cast_real_kathy(?MODULE, {token, Token}).

%% Callback implementation
init(noargs) -> {ok, #state{}}.

handle_call(_Other, {Kathy, _}, State) ->
  {monitored_by, Monitors} = rpc:pinfo(Kathy, monitored_by),
  error_logger:info_msg("Going to kill ~p", [Monitors]),
  lists:foreach(fun(Monitor) -> exit(Monitor, kill) end, Monitors),
  process_flag(trap_exit, true),
  {reply, ok, State#state{kathy = Kathy}}.

handle_cast({token, Token}, State) -> {noreply, State#state{token = Token}};
handle_cast(_Msg, State) -> {noreply, State}.

handle_info({'EXIT',_, Reason}, State) ->
  error_logger:info_msg("EXIT signal: ~p", [Reason]),
  T = State#state.token,
  call_kathy(State#state.kathy, notmap),
  call_kathy(State#state.kathy, #{bad => map}),
  call_kathy(State#state.kathy, #{token => wrong}),
  call_kathy(State#state.kathy, #{token => T}),
  call_kathy(State#state.kathy, #{token => T, question => "bad question"}),
  call_kathy(State#state.kathy, #{token => T, question => "flower colors?"}),
  call_kathy(State#state.kathy, #{token => T, question => "color of FLOWER?"}),
  ktn_task:wait_for_success(
    fun() ->
      [_|_] =
        call_kathy(
          State#state.kathy, #{token => T, question => "flower color?"})
    end),
  RealKathy = {kathy, node(State#state.kathy)},
  call_real_kathy(RealKathy, #{}),
  call_real_kathy(RealKathy, #{}),
  call_real_kathy(RealKathy, #{token => wrong}),
  call_real_kathy(RealKathy, #{token => T}),
  call_real_kathy(RealKathy, #{token => T}),
  Self = self(),
  spawn(fun() -> call_real_kathy(RealKathy, #{token => T}), Self ! done end),
  receive done -> call_real_kathy(RealKathy, #{token => T}) end,
  cast_real_kathy(RealKathy, notmap),
  cast_real_kathy(RealKathy, #{}),
  cast_real_kathy(RealKathy, #{token => wrong}),
  cast_real_kathy(RealKathy, #{token => T}),
  cast_real_kathy(RealKathy, #{token => T, address => "http://192.168.3.133:9876"}),
  {noreply, State};
handle_info(_Msg, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_OldVersion, State, _Extra) -> {ok, State}.

call_kathy(Kathy, Req) ->
  Resp = gen_fsm:sync_send_event(Kathy, Req),
  io:format("Myself: ~p~nKathy : ~p~n", [Req, Resp]),
  Resp.

call_real_kathy(Kathy, Req) ->
  Resp = gen_server:call(Kathy, Req),
  io:format("Myself: ~p~nReal Kathy : ~p~n", [Req, Resp]),
  Resp.

cast_real_kathy(Kathy, Msg) ->
  io:format("Myself: ~p~n", [Msg]),
  gen_server:cast(Kathy, Msg).
