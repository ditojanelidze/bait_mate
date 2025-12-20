import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { postId: Number, offset: Number }

  async load(event) {
    event.preventDefault()

    const response = await fetch(`/posts/${this.postIdValue}/comments?offset=${this.offsetValue}`, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html"
      }
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }
}
