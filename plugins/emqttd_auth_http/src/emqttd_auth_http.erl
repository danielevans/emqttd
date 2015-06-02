%%%-----------------------------------------------------------------------------
%%% Copyright (c) 2012-2015 eMQTT.IO, All Rights Reserved.
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in all
%%% copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%%% SOFTWARE.
%%%-----------------------------------------------------------------------------
%%% @doc
%%% emqttd authentication by mysql 'user' table.
%%%
%%% @end
%%%-----------------------------------------------------------------------------
-module(emqttd_auth_http).

-author("Daniel Evans <evans.daniel.n@gmail.com>").

-include_lib("emqttd/include/emqttd.hrl").

-behaviour(emqttd_auth_mod).

-export([init/1, check/3, description/0]).

-record(state, {url}).

init(Opts) ->
    {ok, #state{url = proplists:get_value(url, Opts)}}.

%% check(#mqtt_client{username = undefined}, _Password, _State) ->
%%     {error, "Username undefined"};
%% check(_Client, undefined, _State) ->
%%     {error, "Password undefined"};
check(#mqtt_client{username = Username}, Password, #state{url = Url}) ->
    io:fwrite(Url),
    case httpc:request(post,
                  {
                    Url, [], "application/x-www-form-urlencoded",
                    "username=" ++ http_uri:encode(binary_to_list(Username)) ++ "&password=" ++ http_uri:encode(binary_to_list(Password))
                  },
                  [], []) of
        {ok, {{_Version, 200, _ReasonPhrase}, _Headers, _Body}} -> ok;
        _Else -> { error, "Unauthorized" }
    end.

description() -> "Authentication by HTTP".
