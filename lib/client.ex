require Logger

defmodule Chitchat.Client do
    use GenServer

    def start_link(sock) do
        GenServer.start_link(__MODULE__, [sock])
    end

    def init(sock) do
        Logger.info "Started client with socket: #{inspect sock}"
        {:ok, HashDict.new}
    end

    ## Test handle for ab test
    def handle_info({:tcp, socket, "\r\n"}, socketDict) do
        ## Flow control: enable forwarding of next TCP message
        ## Logger.info "Flow Control: Received end of headers."
        ## :timer.sleep(:random.uniform(3000))
        :gen_tcp.send(socket, "HTTP/1.0 200 OK\r\nContent-Length: 0\r\n\r\n")
        :gen_tcp.close(socket)
        Logger.info "Flow Control: Closing the connection #{inspect socket}."
        {:stop, :normal, socketDict}
    end

    def handle_info({:tcp, socket, _bin}, socketDict) do
        ## Flow control: enable forwarding of next TCP message
        ## Logger.info "Flow Control: Received data: #{_bin}"
        :inet.setopts(socket, [{:active, :once}])
        {:noreply, socketDict}
    end

    def handle_info({:tcp_closed, socket}, socketDict) do
        Logger.info "Client #{inspect socket} disconnected."
        {:stop, :normal, socketDict}
    end
end
