import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    connect() {
        setTimeout(() => {
            this.element.classList.add("opacity-0", "transition", "duration-500")
            setTimeout(() => this.element.remove(), 2000)
        }, 2000)
    }
}