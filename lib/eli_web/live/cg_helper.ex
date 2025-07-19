defmodule ThreeWeb.Cg.CgHelper do
  use Phoenix.LiveView

  def add_cube(socket, name, x, y, z, color) do
    push_event(socket, "addCube", %{name: name, x: x, y: y, z: z, color: color})
  end

  def add_plane(socket, name, x, y, color) do
    push_event(socket, "addPlane", %{name: name, x: x, y: y, color: color})
  end

  def rotation(socket, name, x, y, z) do
    push_event(socket, "rotation", %{name: name, x: x, y: y, z: z})
  end

  def position(socket, name, x, y, z) do
    push_event(socket, "position", %{name: name, x: x, y: y, z: z})
  end

  def load_model(socket, name, path) do
    push_event(socket, "loadModel", %{name: name, path: path})
  end

  def get_bone(socket, name) do
    push_event(socket, "getBone", %{name: name})
  end

  def rotation_bone(socket, name, bone_name, x, y, z) do
    push_event(socket, "rotationBone", %{name: name, bone_name: bone_name, x: x, y: y, z: z})
  end

  def load_texture(socket, name, path) do
    push_event(socket, "loadTexture", %{name: name, path: path})
  end

  def set_texture(socket, obj_name, texture_name) do
    push_event(socket, "setTexture", %{obj_name: obj_name, texture_name: texture_name})
  end

  @doc """
  Three.jsシーンにCanvasテクスチャでテキストを表示する平面オブジェクトを追加します。
  """
  def add_text_plane(socket, name, text_content, font_size, text_color) do
    push_event(socket, "addTextPlane", %{
      name: name,
      textContent: text_content,
      fontSize: font_size,
      textColor: text_color
    })
  end

  @doc """
  既存のテキスト平面オブジェクトの文字内容とスタイルを更新します。
  """
  def set_text_plane_text(socket, name, new_text_content, font_size, text_color) do
    push_event(socket, "setTextPlaneText", %{
      name: name,
      newTextContent: new_text_content,
      fontSize: font_size,
      textColor: text_color
    })
  end

  @doc """
  Three.jsシーンから指定された名前のオブジェクトを削除します。
  """
  def remove_object(socket, name) do
    push_event(socket, "removeObject", %{name: name})
  end

  def set_size(socket) do
    push_event(socket, "setSize", %{})
  end
end
