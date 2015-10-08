%%%-------------------------------------------------------------------
%%% @author hyunsu
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 9월 2015 오후 3:54
%%%-------------------------------------------------------------------
-module(startfresh_http).
-author("hyunsu").

%% API
-export([init/3, handle/2, terminate/3]).

init(_Type, Req, []) ->
  {ok, Req, no_state}.

handle(Req, State) ->
  {Api, Req1} = cowboy_req:binding(api, Req),
  {What, Req2} = cowboy_req:binding(what, Req1),
  {Opt, Req3} = cowboy_req:binding(opt, Req2),
  %% 데이터 로딩
  {ok, Data, Req4} = cowboy_req:body_qs(Req3),

  io:format("api=~p, what=~p, opt~p ~n", [Api, What, Opt]),

  Reply = handle(Api, What, Opt, Data),

  {ok, Req5} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"text/plain">>}
  ], Reply, Req4),
  {ok, Req5, State}.

handle(<<"login">>, _, _, Data) ->
  Id = proplists:get_value(<<"id">>, Data),
  Password = proplists:get_value(<<"password">>, Data),
  case {Id, Password} of
    {<<"testid">>, <<"testpass">>} ->
      <<"{\"result\":\"ok\"\}">>;
    _ ->
      <<"{\"result\":\"fail\"}">>
  end;
handle(<<"join">>, _, _, _) ->
  <<"{\"result\":\"join\"}">>;
handle(<<"hello">>, <<"world">>, _, _) ->
  <<"{\"result\":\"Hello world!\"}">>;
handle(_, _, _, _) ->
  <<"{\"result\":\"error\"}">>.

terminate(_Reason, _Req, _State) ->
  ok.