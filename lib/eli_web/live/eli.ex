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
    Dify.llm(text)
    |> Speak.speak(14)
    {:noreply, assign(socket, in_data: "")}
  end

  defp initialization_character_data() do
    0
  end

  defp main(socket) do
    t = update(socket.assigns.data)

    arm_ampl = :math.pi() / 8   # radians (~22.5°)
    leg_ampl = :math.pi() / 6   # radians (~30°)
    speed = 4.0                 # oscillation speed

    angle_arm_l = arm_ampl * :math.sin(speed * t)
    angle_arm_r = -arm_ampl * :math.sin(speed * t + 0.5)

    angle_leg_l = leg_ampl * :math.cos(speed * t)
    angle_leg_r = -leg_ampl * :math.cos(speed * t + 0.5)

    socket =
      socket
      |> rotation_bone("test", "J_Bip_R_UpperArm", angle_arm_r, nil, nil)
      |> rotation_bone("test", "J_Bip_L_UpperArm", angle_arm_l, nil, nil)
      |> rotation_bone("test", "J_Bip_R_UpperLeg", angle_leg_r, nil, nil)
      |> rotation_bone("test", "J_Bip_L_UpperLeg", angle_leg_l, nil, nil)

    socket
    |> assign(data: t)
  end

  defp update(character_data) do
    character_data + 0.02
  end
end
