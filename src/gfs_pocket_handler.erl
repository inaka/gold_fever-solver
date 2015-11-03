-module(gfs_pocket_handler).

-export([ init/3
        , allowed_methods/2
        , content_types_accepted/2
        , handle_put/2
        , rest_terminate/2
        ]).

init(_Transport, _Req, _Opts) -> {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) -> {[<<"PUT">>], Req, State}.

content_types_accepted(Req, State) -> {[{'*', handle_put}], Req, State}.

handle_put(Req, State) ->
  {Headers, Req1} = cowboy_req:headers(Req),
  io:format("Headers received:~n~p~n", [Headers]),
  {ok, Body, Req2} = cowboy_req:body(Req1),
  file:write_file("this-just-in", Body),
  io:format("~n~s~n", [os:cmd("ls -la this-just-in")]),
  {true, Req2, State}.

rest_terminate(Req, _State) ->
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
      io:format("~n~n~n   D O N E ! ! !~n~n~n")
    end),
  ok.

call_joe(Inako, Req) ->
  Resp = gen_server:call(Inako, Req),
  io:format("Myself: ~p~nVault : ~p~n", [Req, Resp]),
  Resp.
