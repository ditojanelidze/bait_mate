import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "body"]
  static values = { id: String }

  connect() {
    // Listen for open events
    document.addEventListener(`modal:open:${this.idValue}`, this.open.bind(this))
  }

  disconnect() {
    document.removeEventListener(`modal:open:${this.idValue}`, this.open.bind(this))
  }

  open(event) {
    // If event has HTML content, insert it
    if (event.detail?.html) {
      this.bodyTarget.innerHTML = event.detail.html
    }

    this.element.classList.remove("hidden")
    document.body.style.overflow = "hidden"

    // Animate in
    requestAnimationFrame(() => {
      this.contentTarget.classList.remove("translate-y-full")
    })
  }

  close() {
    this.contentTarget.classList.add("translate-y-full")
    document.body.style.overflow = ""

    setTimeout(() => {
      this.element.classList.add("hidden")
    }, 300)
  }

  // Close on escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
