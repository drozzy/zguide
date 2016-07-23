%% Hellow World server
-module(hwserver).
-export([main/0]).
main() ->
    % Socket to talk to clients
    {ok, Socket} = erlangzmq:socket(rep),

    {ok, _} = erlangzmq:bind(Socket, tcp, "localhost", 5555),

    loop(Socket).
    
loop(Socket) ->
    {ok, Hello} = erlangzmq:recv(Socket),

    io:format("Received ~s~n", [Hello]),

    % Do some 'work'
    timer:sleep(1000),

    ok = erlangzmq:send(Socket, <<"World">>),
    loop(Socket).
