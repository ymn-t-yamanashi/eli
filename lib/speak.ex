defmodule Speak do
  def speak(text, id) do
    param = URI.encode_query(%{text: text, speaker: 1})

    json =
      ("http://localhost:50021/audio_query?" <> param)
      |> Req.post!(body: "")
      |> Map.get(:body)
      |> Jason.encode!()

    headers = ["Content-Type": "application/json"]

    data =
      "http://localhost:50021/synthesis?speaker=#{id}"
      |> Req.post!(body: json, headers: headers)
      |> Map.get(:body)

    File.rm("hoge.wav")
    File.write("hoge.wav", data)
    System.cmd("aplay", ["hoge.wav"])
    text
  end
end
