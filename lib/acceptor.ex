require Logger

defmodule Chitchat.Acceptor do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, :ok, name: Acceptor)
    end

    def init(:ok) do
        {:ok, listenSocket} = :gen_tcp.listen(8888, [:binary, {:packet, :line}, {:active, false}, {:reuseaddr, true}, {:backlog, 200}, {:keepalive, true}])
        {:ok, ref} = :prim_inet.async_accept(listenSocket, -1)
        socketDict = HashDict.new()
                     |> HashDict.put(:listener, listenSocket)
                     |> HashDict.put(:acceptor, ref)
        Logger.info "Listenning on socket: #{inspect listenSocket}"
        {:ok, socketDict}
    end

    def handle_info({:inet_async, listenSocket, _ref, {:ok, clientSocket}}, socketDict) do
        Logger.info "Client connected: #{inspect clientSocket}"
        set_sockopt(listenSocket, clientSocket)

        ## Start the client and transfer the socket to it
        {:ok, clientPid} = Chitchat.ClientSup.start_client(ChitchatClientSup, clientSocket)
        :gen_tcp.controlling_process(clientSocket, clientPid)

        ## Help the client to start receiving data
        :inet.setopts(clientSocket, [{:active, :once}])

        ## Start accepting the new clients
        {:ok, newRef} = :prim_inet.async_accept(listenSocket, -1)
        {:noreply, HashDict.put(socketDict, :acceptor, newRef)}
    end

    ## Taken from prim_inet.  We are merely copying some socket options from the
    ## listening socket to the new client socket.
    def set_sockopt(listenSock, cliSock) do
        true = :inet_db.register_socket(cliSock, :inet_tcp)
        case :prim_inet.getopts(listenSock, [:active, :nodelay, :keepalive, :delay_send, :priority, :tos]) do
            {:ok, opts} ->
                case :prim_inet.setopts(cliSock, opts) do
                    :ok   -> :ok
                    error -> :gen_tcp.close(cliSock)
                    error
                    end
            error ->
                :gen_tcp.close(cliSock)
                error
        end
    end
end
