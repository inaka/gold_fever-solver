-module(gfs_app_SUITE).
-author('elbrujohalcon@inaka.net').

-export([all/0]).
-export([run/1]).

-spec all() -> [atom()].
all() -> [run].

-spec run(proplists:proplist()) -> {comment, []}.
run(_Config) ->
  {ok, _} = gold_fever_solver:start(),
  ok = gold_fever_solver:stop(),
  {comment, ""}.
