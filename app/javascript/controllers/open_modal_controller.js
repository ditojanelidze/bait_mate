import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  async open(event) {
    event.preventDefault()

    const url = event.params.url
    const targetModal = event.params.target

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const html = await response.text()

        // Dispatch event to open the modal with content
        const modalEvent = new CustomEvent(`modal:open:${targetModal}`, {
          detail: { html }
        })
        document.dispatchEvent(modalEvent)
      }
    } catch (error) {
      console.error("Error loading modal content:", error)
    }
  }
}
