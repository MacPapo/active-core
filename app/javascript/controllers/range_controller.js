import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="range"
export default class extends Controller {
    static targets = ["range"];

    connect() {
        console.log("RANGE CONTROLLER CONNECTED");
        this.updateRangeValue();
    }

    updateRangeValue(event) {
        const rangeInput = event ? event.target : this.element.querySelector('.form-range');
        const value = rangeInput.value;
        this.rangeTarget.textContent = value;
    }
}
