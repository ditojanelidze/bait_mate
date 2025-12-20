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
        this.previewTarget.classList.remove("hidden")
      } else {
        // Create new image element
        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "max-h-48 mx-auto rounded-lg mb-4"
        img.dataset.imagePreviewTarget = "preview"

        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.replaceWith(img)
        }
      }
    }
    reader.readAsDataURL(file)
  }
}
