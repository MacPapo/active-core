import { Controller } from "@hotwired/stimulus"
import debounce from "debounce";

// Connects to data-controller="filters"
export default class extends Controller {
    static targets = ["panel"]

    connect() {
        console.log("Filters Controller connected");
    }

    initialize() {
        this.submit = debounce(this.submit.bind(this), 200);
    }

    toggle() {
        this.panelTarget.style.display = this.panelTarget.style.display === "none" ? "block" : "none";
    }

    submit(event) {
        event.target.form.requestSubmit();
    }
}
