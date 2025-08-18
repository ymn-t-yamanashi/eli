defmodule EliWeb.Eli do
  use EliWeb, :live_view
  import ThreeWeb.Cg.CgHelper

  @impl true
  def mount(_params, _session, socket) do
    Process.send_after(self(), :update, 500)

    socket =
      socket
      |> assign(in_data: "")
      |> set_size()
      |> assign(data: initialization_character_data())
      |> load_model("test", "/images/eli.vrm")
      |> add_text_plane("my_greeting", "Eli", 20, "#CC5500")
      |> position("my_greeting", -1.7, 3.5, 0)

    {:ok, main(socket)}
  end

  @impl true
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 20)
    {:noreply, main(socket)}
  end

  def handle_event("load_model", %{"name" => "test", "status" => "completion"}, socket) do
    socket =
      socket
      |> position("test", 0, -1.4, 4.6)
      |> rotation("test", 0, 3.2, 0)
      |> rotation_bone("test", "J_Bip_R_UpperArm", -1.0, 1.2, 0.0)
      |> rotation_bone("test", "J_Bip_L_UpperArm", -1.0, -1.2, 0.0)
      |> get_bone("test")

    {:noreply, socket}
  end

  def handle_event("get_bone", %{"name" => name}, socket) do
    IO.inspect(name)
    {:noreply, socket}
  end

  def handle_event("update_text", %{"input_text" => text}, socket) do
    {:noreply, assign(socket, in_data: text)}
  end

  def handle_event("my_form_submit_event", %{"input_text" => text}, socket) do
    # Start async task to avoid blocking LiveView
    Task.start(fn ->
      try do
        client = Ollama.init()

        {:ok, ret} =
          Ollama.completion(client,
            model: "gemma3:1b-it-qat",
            system: "私は会話をします。私は会話の為かならず100文字以内に返事をします。",
            prompt: text
          )

        response = Map.get(ret, "response")
        Speak.speak(response, 14)

        send(self(), {:my_form_complete, :ok})
      rescue
        e -> send(self(), {:my_form_error, Exception.message(e)})
      end
    end)

    # Show loading state (optional)
    {:noreply, assign(socket, loading: true)}
  end

  def handle_info({:my_form_complete, _}, socket) do
    {:noreply, assign(socket, in_data: "", loading: false)}
  end

  def handle_info({:my_form_error, msg}, socket) do
    IO.puts("Error in my_form_submit_event: #{msg}")
    {:noreply, assign(socket, in_data: "", loading: false)}
  end

  defp initialization_character_data() do
    0
  end

  defp main(socket) do
    character_data = update(socket.assigns.data)

    sin = :math.sin(character_data) * 0.05

    socket
    |> rotation("test", 0.01, 3.2, sin)
    |> assign(data: character_data)
  end

  defp update(character_data) do
    character_data + 0.02
  end
end
