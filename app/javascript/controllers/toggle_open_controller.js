import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-open"
export default class extends Controller {
    static targets = ["openField", "activitySelect"];

    connect() {
        console.log('TOGGLE CONNECTED!');
        this.toggleOpenField();
    }

    toggleOpenField() {
        const selectedValue = this.extractValue();
        if (selectedValue !== '') {

            fetch(`/activities/${selectedValue}/name`, {
                headers: { "Accept": "application/json" }
            })
                .then(response => response.json())
                .then(data => {
                    var target = this.openFieldTarget.classList;
                    data.name == 'Sala pesi' ? target.add('d-none') : target.remove('d-none');
                })
        } else {
            this.openFieldTarget.classList.add('d-none');
        }
    }

    extractValue() {
        const activities = this.activitySelectTarget.options
        if (activities !== undefined) {
            return activities[activities.selectedIndex].value
        } else {
            return this.activitySelectTarget.value;
        }
    }
}
