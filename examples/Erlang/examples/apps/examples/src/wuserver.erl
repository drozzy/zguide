%% Weather update server
%% Binds PUB socket to tcp:/*:5556
%% Publishes random weather updates
-module(wuserver).

-export([main/0]).

main() ->
	% Prepare our publisher
	{ok, Publisher} = erlangzmq:socket(pub),
	{ok, _} = erlangzmq:bind(Publisher, tcp, "localhost", 5556),

	loop(Publisher).

loop(Publisher) ->
	% Get values that will fool the boss
	ZipCode = rand:uniform(100000),
	Temperature = rand:uniform(215) - 80,
	RelHumidity = rand:uniform(50) + 10,

	% Send message to all subscribers
	Update = iolist_to_binary(
		io_lib:format("~5..0b ~b ~b", 
			[ZipCode, Temperature, RelHumidity])),
	ok = erlangzmq:send(Publisher, Update),
	loop(Publisher).
