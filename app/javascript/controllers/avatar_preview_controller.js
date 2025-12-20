import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "placeholder"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = e.target.result
      } else if (this.hasPlaceholderTarget) {
        // Create new image element for avatar
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "w-28 h-28 rounded-full object-cover border-4 border-gray-200 mx-auto"
        img.dataset.avatarPreviewTarget = "preview"
        this.placeholderTarget.replaceWith(img)
      }
    }
    reader.readAsDataURL(file)
  }
}
