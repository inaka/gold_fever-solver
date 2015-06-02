%%% @doc main gold_fever_solver supervisor
-module(gfs_sup).
-behavior(supervisor).

-export([start_link/0, init/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Start / Stop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% @doc Starts the Supervisor
-spec start_link() -> {ok, pid()}.
start_link() -> supervisor:start_link({local, ?MODULE}, ?MODULE, noargs).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUPERVISOR CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% @private
-spec init(noargs) -> {ok, {{one_for_one, 5, 10}, [supervisor:child_spec()]}}.
init(noargs) ->
  Larry =
    {larry, {gfs_larry, start_link, []}, permanent, 5000, worker, [gfs_larry]},
  Server =
    {server,
      {gfs_server, start_link, []}, permanent, 5000, worker, [gfs_server]},
  {ok, {{one_for_one, 5, 10}, [Larry, Server]}}.
