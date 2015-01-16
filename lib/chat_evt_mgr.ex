require Logger

defmodule ChitChat.ChatEvtMgr do
    use GenEvent

    def init() do
        {:ok, HashDict.new()}
    end

    def handle_event({:log, x}, messages) do
        {:ok, [x|messages]}
    end

    def handle_call(:messages, messages) do
        {:ok, Enum.reverse(messages), []}
    end

end
