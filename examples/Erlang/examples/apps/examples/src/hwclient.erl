%% Hello World client
-module(hwclient).
-export([main/0]).

main() ->
    io:format("Connecting to hello world server...~n"),
    {ok, Socket} = erlangzmq:socket(req),

    {ok, _} = erlangzmq:connect(Socket, tcp, "localhost", 5555),

    loop(Socket).

loop(Socket) -> loop(Socket, 0).

loop(_, 10) -> ok;
loop(Socket, RequestNbr) ->
    io:format("Sending Hello ~b...~n", [RequestNbr]),
    ok = erlangzmq:send(Socket, <<"Hello">>),

    {ok, Reply} = erlangzmq:recv(Socket),
    io:format("Received ~s ~b~n", [Reply, RequestNbr]),
    loop(Socket, RequestNbr + 1).

