require Logger

defmodule ChitChat.ClientEvtMgr do
    use GenEvent

    def list_clients do
        GenEvent.call(:ClientMgr, ChitChat.ClientEvtMgr, {:list_clients})
    end
    
    def init(_args) do
        {:ok, HashDict.new()}
    end

    def handle_event({:new_client, {pid}}, clientDict) do
        {:ok, HashDict.put(clientDict, pid, HashDict.new())}
    end

    def handle_call({:list_clients}, clientDict) do
        {:ok, HashDict.to_list(clientDict), clientDict}
    end

end
