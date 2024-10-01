import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
    static targets = ["panel"]

    connect() {
        console.log("Filters Controller connected");
    }

    toggle() {
        this.panelTarget.style.display = this.panelTarget.style.display === "none" ? "block" : "none";
    }

    submit(event) {
        console.log("SUBMITTED");
        event.target.form.requestSubmit();
    }
}
