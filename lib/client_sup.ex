require Logger

defmodule ChitChat.ClientSup do
    use Supervisor

    def start_link(_opts \\ []) do
        Supervisor.start_link(__MODULE__, :ok, _opts)
    end

    def start_client(supervisor, sock) do
        Supervisor.start_child(supervisor, [sock])
    end

    def init(:ok) do

        GenEvent.add_mon_handler(:ClientMgr, ChitChat.ClientEvtMgr, [])
        GenEvent.add_mon_handler(:ChatMgr, ChitChat.ChatEvtMgr, [])

        children = [
            worker(ChitChat.Client, [], restart: :temporary)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end
