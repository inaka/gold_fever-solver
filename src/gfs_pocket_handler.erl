-module(gfs_pocket_handler).

-export([ init/3
        , allowed_methods/2
        , content_types_accepted/2
        , handle_put/2
        ]).

init(_Transport, _Req, _Opts) -> {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) -> {[<<"PUT">>], Req, State}.

content_types_accepted(Req, State) -> {[{'*', handle_put}], Req, State}.

handle_put(Req, State) ->
  {Headers, Req1} = cowboy_req:headers(Req),
  io:format("Headers received:~n~p~n", [Headers]),
  {ok, Body, Req2} = cowboy_req:body(Req1),
  file:write_file("this-just-in", Body),
  os:cmd("open this-just-in"),
  {true, Req2, State}.
