-module(gfs_joe).

-export([find/0]).

find() ->
  io:format("Is joe here? ~p~n", [nodes()]),
  io:format("What about here? ~p~n", [nodes(hidden)]),

  net_adm:world(),

  io:format("Is joe here? ~p~n", [nodes()]),
  Nodes = nodes(hidden),
  io:format("What about here? ~p~n", [Nodes]),

  [JoeNode] =
    [Node || Node <- Nodes
           , "joe" == hd(string:tokens(atom_to_list(Node), [$@]))
           ],
  JoeVault = {vault, JoeNode},

  "Vault locked" ++ _ = call_joe(JoeVault, contents),
  <<"Wrong k", _/binary>> = call_joe(JoeVault, wrongpwd),
  "Vault locked" ++ _ = call_joe(JoeVault, contents),
  <<"Wrong k", _/binary>> = call_joe(JoeVault, wrongpwd),
  <<"Wrong k", _/binary>> = call_joe(JoeVault, wrongpwd),
  <<"Wrong k", _/binary>> = call_joe(JoeVault, wrongpwd),
  "Vault locked" ++ _ = call_joe(JoeVault, wrongpwd),
  "Vault unlocke" ++ _ = call_joe(JoeVault, wrongpwd),
  "Vault unlocke" ++ _ = call_joe(JoeVault, wrongpwd),
  "http://ow.ly/NQkbK" = call_joe(JoeVault, contents),
  "http://ow.ly/NQkbK" = call_joe(JoeVault, contents),

  spawn(
    fun() ->
      "Vault unlocke" ++ _ = call_joe(JoeVault, letitcrash),
      "http://ow.ly/NQmoH" = call_joe(JoeVault, contents),
      io:format("~n~n~n   D O N E ! ! !~n~n~n"),
      os:cmd("open http://ow.ly/NQmoH"),
      erlang:halt()
    end),
  ok.

call_joe(Inako, Req) ->
  Resp = gen_server:call(Inako, Req),
  io:format("Myself: ~p~nVault : ~p~n", [Req, Resp]),
  Resp.
