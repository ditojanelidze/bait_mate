import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { postId: Number }

  connect() {
    this.element.addEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmitEnd.bind(this))
  }

  handleSubmitEnd(event) {
    if (event.detail.success) {
      // Clear the input
      if (this.hasInputTarget) {
        this.inputTarget.value = ""
      }

      // Reload comments in the modal
      this.reloadComments()
    }
  }

  async reloadComments() {
    const url = `/posts/${this.postIdValue}/comments/modal`

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()

        // Update modal body content
        const modalBody = document.getElementById("comments-modal-content")
        if (modalBody) {
          modalBody.innerHTML = html
        }
      }
    } catch (error) {
      console.error("Error reloading comments:", error)
    }
  }
}
