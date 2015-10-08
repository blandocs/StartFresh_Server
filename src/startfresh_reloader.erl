%%%-------------------------------------------------------------------
%%% @author hyunsu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 9¿ù 2015 ¿ÀÈÄ 6:16
%%%-------------------------------------------------------------------
-module(startfresh_reloader).
-author("hyunsu").

-include_lib("kernel/include/file.hrl").


%% API
-export([start/0, loop/1, reload/1]).

start() ->
  Pid = spawn(startfresh_reloader, loop, [erlang:localtime()]),
  timer:send_interval(timer:seconds(1), Pid, check).

loop(From) ->
  receive
    check ->
      To = erlang:localtime(),
      [check(From, To, Module, Filename)
        ||  {Module, Filename} <- code:all_loaded(), is_list(Filename)],
      loop(To);
    update ->
      ?MODULE:loop(From);
    Other ->
      io:format("~p~n",[Other]),
      loop(From)
  end.

check(From, To, Module, Filename) ->
  case file:read_file_info(Filename) of
    {ok, #file_info{mtime=MTime}} when MTime >= From, MTime < To ->
      reload(Module);
    _ ->
      pass
  end.

reload(Module) ->
  io:format("Reloading ~p ...", [Module]),
  code:purge(Module),
  code:load_file(Module),
  io:format(" ok. ~n").
