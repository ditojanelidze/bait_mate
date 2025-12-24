import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header"]

  connect() {
    this.lastScrollY = window.scrollY
    this.ticking = false

    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    if (!this.ticking) {
      window.requestAnimationFrame(() => {
        this.updateHeader()
        this.ticking = false
      })
      this.ticking = true
    }
  }

  updateHeader() {
    const currentScrollY = window.scrollY

    if (currentScrollY > this.lastScrollY && currentScrollY > 60) {
      // Scrolling down & past header height - hide header
      this.headerTarget.classList.add("-translate-y-full")
    } else {
      // Scrolling up - show header
      this.headerTarget.classList.remove("-translate-y-full")
    }

    this.lastScrollY = currentScrollY
  }
}
