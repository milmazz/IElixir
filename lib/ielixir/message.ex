defmodule IElixir.Message do
  @moduledoc """
  This is documentation for Message structure and some utils that helps in
  encoding, parsing, assembling and sending messages.

  Here are extracted functions which helps with messages management.
  """

  require Logger
  alias IElixir.HMAC

  defstruct uuid: nil,
    baddad42: nil,
    header: nil,
    parent_header: nil,
    metadata: nil,
    content: nil,
    blob: nil

  @doc false
  def encode(message) do
    header = Poison.encode!(message.header)
    parent_header = Poison.encode!(message.parent_header)
    metadata = Poison.encode!(message.metadata)
    content = Poison.encode!(message.content)

    message = [
      message.uuid,
      "<IDS|MSG>",
      HMAC.compute_signature(header, parent_header, metadata, content),
      header,
      parent_header,
      metadata,
      content
    ]
    Logger.debug("Message encoded: #{inspect message}")
    message
  end

  @doc false
  def parse([uuid, "<IDS|MSG>", baddad42, header, parent_header, metadata, content | blob]) do
    %IElixir.Message{uuid: uuid,
      baddad42: baddad42,
      header: Poison.Parser.parse!(header),
      parent_header: Poison.Parser.parse!(parent_header),
      metadata: Poison.Parser.parse!(metadata),
      content: Poison.Parser.parse!(content),
      blob: blob}
  end
  def parse(message) do
    Logger.warn("Invalid message on shell socket #{inspect message}")
  end

  @doc false
  def assemble_message({:zmq, _, message, flags}, {sock, message_buffer}, process_fun) do
    case assemble_message_part(message, flags, message_buffer) do
      {:buffer, buffer} ->
        {sock, buffer}
      {:msg, message} ->
        process_fun.(message.header["msg_type"], message, sock)
        {sock, []}
    end
  end

  defp assemble_message_part(message, flags, message_buffer) do
    message_buffer = [message | message_buffer]
    if :rcvmore in flags do
      {:buffer, message_buffer}
    else
      {:msg, parse(Enum.reverse(message_buffer))}
    end
  end

  @doc false
  def send_message(sock, message, message_type, content) do
    new_message = %{message |
      "parent_header": message.header,
      "header": %{message.header |
        "msg_type" => message_type
      },
      "content": content
    }
    send_all(sock, encode(new_message))
  end

  @doc false
  def send_all(sock, [message]) do
    :ok = :erlzmq.send(sock, message, [])
  end
  def send_all(sock, [message | other_messages]) do
    :ok = :erlzmq.send(sock, message, [:sndmore])
    send_all(sock, other_messages)
  end
end

