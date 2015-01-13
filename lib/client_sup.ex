require Logger

defmodule Chitchat.ClientSup do
    use Supervisor

    def start_link(_opts \\ []) do
        Supervisor.start_link(__MODULE__, :ok, name: ChitchatClientSup)
    end

    def start_client(supervisor, sock) do
        Supervisor.start_child(supervisor, [sock])
    end

    def init(:ok) do

        children = [
            worker(Chitchat.Client, [], restart: :temporary)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end
