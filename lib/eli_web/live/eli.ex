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
      |> position("test", 0, -1, 3)
      |> rotation("test", 0, 3.2, 0)
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
        {:ok, ret} = Ollama.completion(client,
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

    socket
    |> rotation_bone("test", "J_Bip_R_UpperArm", character_data, character_data, character_data)
    |> rotation_bone("test", "J_Bip_L_UpperArm", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_L_UpperLeg", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_L_LowerLeg", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_L_ToeBase", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_R_LowerLeg", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_R_ToeBase", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_C_Neck", character_data, character_data, character_data)
    # |> rotation_bone("test", "J_Bip_C_Hips", character_data, character_data, character_data)
    |> assign(data: character_data)
  end

  defp update(character_data) do
    character_data + 0.02
  end
end