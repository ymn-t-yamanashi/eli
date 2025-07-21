defmodule Dify do
  @moduledoc """
  Documentation for `Dify`.
  """
  def llm(str) do
   #api =  %{"1" =>  "app-hbwsnSNeAaaMXi6UEDvYI2uP", "2" => "app-KrVNFLmTjBZoPehsN6njTMcU"}

    headers = [
      "Content-Type": "application/json",
      Authorization: "Bearer app-iMxgcxM30CvnUTeb4I7qG4yB"
    ]

    json = """
    {
      "inputs": {},
      "query": "#{str}",
      "response_mode": "blocking",
      "conversation_id": "",
      "user": "abc-123"
    }
    """

    "http://localhost:4080/v1/chat-messages"
    |> Req.post!(headers: headers, body: json, connect_options: [timeout: 1_000_000])
    |> Map.get(:body)
    |> Map.get("answer")
  end
end
