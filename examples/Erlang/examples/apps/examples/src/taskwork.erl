%% Task worker
%% Connects PULL socket to tcp://localhost:5557
%% Collects workloads from ventilator via that socket
%% Connects PUSH socket to tcp://localhost:5558
%% Sends results to sink via that socket
-module (taskwork).
-export([main/0]).

main() ->
	% Socket to receive messages on
	{ok, Receiver} = erlangzmq:socket(pull),
	{ok, _} = erlangzmq:connect(Receiver, tcp, "localhost", 5557),

	% Socket to send messages on
	{ok, Sender} = erlangzmq:socket(push),
	{ok, _} = erlangzmq:connect(Sender, tcp, "localhost", 5558),

	% Process tasks forever
	loop(Receiver, Sender).

loop(Receiver, Sender) ->
	{ok, String} = erlangzmq:recv(Receiver),

	% Show progress
	io:format("~s~n", [String]),

	% Do the work
	timer:sleep(binary_to_integer(String)),

	% Send results to sink
	erlangzmq:send(Sender, <<>>),

	loop(Receiver, Sender).


	