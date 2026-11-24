module ImageManifestHelper
  # Список наявних файлів із логотипами брендів і картинками типів (щоб браузер не вгадував назви)
  def image_manifest
    root = Rails.root.join("public").to_s
    Dir.glob(Rails.root.join("public", "images", "{brands,types}", "*")).map { |path| path.sub(root, "") }
  end
end