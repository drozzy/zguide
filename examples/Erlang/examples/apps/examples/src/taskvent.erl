%% Task ventilator
%% Binds PUSH socket to tcp://localhost:5557
%% Sends batch of tasks to workers via that socket
-module(taskvent).
-export([main/0]).

main() ->
	% Socket to send messages on
	{ok, Sender} = erlangzmq:socket(push),
	{ok, _} = erlangzmq:bind(Sender, tcp, "localhost", 5557),

	% Socket to send start of batch message on
	{ok, Sink} = erlangzmq:socket(push),
	{ok, _} = erlangzmq:connect(Sink, tcp, "localhost", 5558),

	io:get_line("Press Enter when the workers are ready: "),
	io:format("Sending tasks to workers...~n", []),

	% The first message is "0" and signals the start of the batch
	erlangzmq:send(Sink, <<"0">>),

	% Send 100 tasks
	TotalMsec = send_tasks(100, Sender),

	io:format("Total expected cost: ~b msec~n", [TotalMsec]).

send_tasks(N, Socket) -> send_tasks(0, N, Socket, 0).

send_tasks(N, N, _, Acc) -> Acc;
send_tasks(X, N, Socket, Acc) ->
	% Random workload from 1 to 100msecs
	Workload = rand:uniform(100),
	String = iolist_to_binary(
		io_lib:format("~b", [Workload])),
	ok = erlangzmq:send(Socket, String),

	send_tasks(X + 1, N, Socket, Acc + Workload).
