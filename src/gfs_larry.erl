-module(gfs_larry).

-export([start_link/0, loop/0]).

-spec start_link() -> {ok, pid()}.
start_link() ->
  Pid = proc_lib:spawn_link(?MODULE, loop, []),
  register(larry, Pid),
  {ok, Pid}.

-spec loop() -> no_return().
loop() ->
  receive
    #{kathy := K, token := T} ->
      gfs_server:token(T),
      K ! not_flowers,
      K ! flower,
      K ! notmap,
      K ! #{bad => map},
      K ! #{token => wrong},
      K ! #{token => T},
      K ! #{token => T, gen_server => {gfs_server, node()}};
    X -> error_logger:warning_msg("Larry got ~p", [X])
  end,
  loop().
