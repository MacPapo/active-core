import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="activity-search-user"
export default class extends Controller {
    static targets = ["input", "results", "hiddenUserId", "plans"]

    connect() {
        console.log("User search controller connected!")
    }

    search() {
        const query = this.inputTarget.value

        if (query.length > 2) {
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
        } else {
            this.resultsTarget.innerHTML = ""
        }
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

        // Se l'activityId è vuoto o corrisponde al prompt, interrompi la funzione
        if (!activityId) {
            this.plansTarget.innerHTML = ""; // Resetta i piani selezionabili
            return;
        }

        // Effettua una chiamata AJAX per ottenere i piani associati all'attività selezionata
        fetch(`/activities/${activityId}/plans`)
            .then(response => response.json())
            .then(data => {
                const plansSelect = this.plansTarget;
                plansSelect.innerHTML = ""; // Svuota il select

                data.plans.forEach(plan => {
                    const option = document.createElement("option");
                    option.value = plan.id;
                    option.text = plan.name;
                    plansSelect.appendChild(option);
                });
            });
    }
}
