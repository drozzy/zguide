-module(version).
-export([main/0]).

main() ->
    % {ok, Version} = application:get_key(erlangzmq, vsn),
    {Major, Minor, Patch} = erlangzmq:version(),
    io:format("Current 0MQ version is ~b.~b.~b~n", [Major, Minor, Patch]).
