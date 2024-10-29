import { Controller } from "@hotwired/stimulus"
import debounce from "debounce";

// Connects to data-controller="activity-search-user"
export default class extends Controller {
    static targets = ["input", "results", "hiddenUserId", "plans"]

    connect() {
        console.log("User search controller connected!")
    }

    initialize() {
        this.search = debounce(this.search.bind(this), 200);
    }

    search() {
        const query = this.inputTarget.value

        fetch(`/users/activity_search?query=${query}`, {
            headers: { "Accept": "application/json" }
        })
            .then(response => response.json())
            .then(data => {
                this.resultsTarget.innerHTML = data.map(user => `
                    <option value="${user.name} ${user.surname}" data-id="${user.id}">
                        ${user.name} ${user.surname} (${user.birth_day})
                    </option>
                `).join("")
            })
    }

    selectUser() {
        const selectedOption = Array.from(this.resultsTarget.options).find(
            option => option.value === this.inputTarget.value
        );

        if (selectedOption) {
            const userId = selectedOption.dataset.id;
            if (userId) {
                this.hiddenUserIdTarget.value = userId;
            }
        } else {
            this.hiddenUserIdTarget.value = '';
        }
    }

    loadPlans(event) {
        const activityId = event.target.value;

        if (!activityId) {
            this.plansTarget.innerHTML = "";
            return;
        }

        fetch(`/activities/${activityId}/plans`)
            .then(response => response.json())
            .then(data => {
                const plansSelect = this.plansTarget;
                plansSelect.innerHTML = "";

                data.plans.forEach(plan => {
                    const option = document.createElement("option");
                    option.value = plan.id;
                    option.text = plan.name;
                    plansSelect.appendChild(option);
                });
            });
    }
}
