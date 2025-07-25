import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
    static targets = [ "alert" ]

    connect() {
        this.alertTargets.forEach((el) => {
            setTimeout(() => {
                el.classList.remove("show") // trigger fade out
                setTimeout(() => el.remove(), 500) // remove after fade
            }, 3000)
        })
    }
}
