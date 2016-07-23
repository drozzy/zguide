%% Weather update client
%% Connects SUB socket to tcp://localhost:5556
%% Collects weather updates and finds avg temp in zipcode
-module(wuclient).
-export([main/0, main/1]).

main() -> main([]).
main(Args) ->
	% Socket to talk to server
	io:format("Collecting updates from weather server...~n", []),
	Filter = case Args of
		[Arg] -> list_to_binary(Arg);
		[] -> <<"10001 ">>
	end,
	{ok, Subscriber} = erlangzmq:socket(sub),
	erlangzmq:subscribe(Subscriber, Filter),
	{ok, _} = erlangzmq:connect(Subscriber, tcp, "localhost", 5556),

	% Process 10 updates
	N = 10,
	TotalTemp = average_temperature(Subscriber, N),

	io:format("Average temperature for zipcode '~s' was ~bF~n", 
		[Filter, round(TotalTemp/N)]).

average_temperature(Subscriber, N) -> average_temperature(Subscriber, 1, N, 0).

average_temperature(_, X, X, TotalTemp) -> TotalTemp;
average_temperature(Subscriber, X, N, TotalTemp) ->
	{ok, String} = erlangzmq:recv(Subscriber),
	io:format("Received at ~p~n", [X]),
	Temp = parse_temperature(String),
	average_temperature(Subscriber, X+1, N, TotalTemp + Temp).


parse_temperature(String) ->	
	{ok, [_, Temp, _], _} = io_lib:fread("~d ~d ~d", binary_to_list(String)),
	Temp.
