%% Task sink
%% Binds PULL socket to tcp://localhost:5558
%% Collects results from workers via that socket
-module (tasksink).
-export([main/0]).

main() ->
	% Prepare our socket
	{ok, Receiver} = erlangzmq:socket(pull),
	{ok, _} = erlangzmq:bind(Receiver, tcp, "localhost", 5558),

	% Wait for start of batch
	{ok, _} = erlangzmq:recv(Receiver),

	% Start our clock now
	TStart = erlang:monotonic_time(milli_seconds),

	% Process 100 confirmations
	process_confirmations(Receiver, 100),

	% Calculate and report duration of batch
	TEnd = erlang:monotonic_time(milli_seconds),

	io:format("Total elapsed time: ~b msec~n", [TEnd - TStart]).


process_confirmations(Socket, N) ->
	process_confirmations(Socket, 1, N + 1).

process_confirmations(_, X, X) -> ok;
process_confirmations(Socket, X, N) ->
	{ok, _} = erlangzmq:recv(Socket),
	case X rem 10 of
		0 -> io:format(":~n");
		_ -> io:format(".")
	end,
	process_confirmations(Socket, X + 1, N).



