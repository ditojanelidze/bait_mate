import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrollContainer", "list", "sentinel"]
  static values = {
    postId: Number,
    offset: Number,
    hasMore: Boolean,
    loading: { type: Boolean, default: false }
  }

  connect() {
    if (this.hasMoreValue && this.hasSentinelTarget) {
      this.setupObserver()
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupObserver() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && this.hasMoreValue && !this.loadingValue) {
            this.loadMore()
          }
        })
      },
      {
        root: this.scrollContainerTarget,
        rootMargin: "100px",
        threshold: 0.1
      }
    )

    this.observer.observe(this.sentinelTarget)
  }

  async loadMore() {
    if (this.loadingValue || !this.hasMoreValue) return

    this.loadingValue = true

    try {
      const response = await fetch(`/posts/${this.postIdValue}/comments/more?offset=${this.offsetValue}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (response.ok) {
        const data = await response.json()

        // Append new comments
        if (data.html && this.hasListTarget) {
          this.listTarget.insertAdjacentHTML("beforeend", data.html)
        }

        // Update offset
        this.offsetValue = data.new_offset

        // Check if there are more comments
        this.hasMoreValue = data.has_more

        // Hide spinner if no more comments
        if (!this.hasMoreValue && this.hasSentinelTarget) {
          this.sentinelTarget.innerHTML = ""
        }
      }
    } catch (error) {
      console.error("Error loading more comments:", error)
    } finally {
      this.loadingValue = false
    }
  }
}
