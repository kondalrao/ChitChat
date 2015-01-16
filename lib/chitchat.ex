defmodule ChitChat do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(GenEvent, [[name: :ClientMgr]], id: :ClientEvtMgr),
      worker(GenEvent, [[name: :ChatMgr]], id: :ChatEvtMgr),
      worker(ChitChat.Acceptor, [[name: :ChitChatAcceptor]]),
      supervisor(ChitChat.ClientSup, [[name: :ChitChatClientSup]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChitChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
