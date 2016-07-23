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
	_String = erlangzmq:recv(Receiver),

	% Start our clock now
	StartTime = erlang:monotonic_time(milli_seconds),

	% Process 100 confirmations
	process_confirmations(Receiver, 100),

	EndTime = erlang:monotonic_time(milli_seconds),

	Elapsed = EndTime - StartTime,
	io:format("Total elapsed time: ~b msec~n", [Elapsed]).


process_confirmations(Socket, N) ->
	process_confirmations(Socket, 1, N).

process_confirmations(_, X, X) -> ok;
process_confirmations(Socket, X, N) ->
	String = erlangzmq:recv(Socket),
	case X rem 10 of
		0 -> io:format(":~n", []);
		_ -> io:format(".", [])
	end,
	process_confirmations(Socket, X + 1, N).



