import { Controller } from "@hotwired/stimulus"
import debounce from "debounce";

// Connects to data-controller="activity-search-user"
export default class extends Controller {
    static targets = ["input", "results", "hiddenUserId", "name", "surname", "email", "phone"]

    connect() {
        console.log("User search controller connected!")
    }

    initialize() {
        this.search = debounce(this.search.bind(this), 200);
    }

    search() {
        const query = this.inputTarget.value;
        fetch(`/users/activity_search?query=${encodeURIComponent(query)}`, {
            headers: { "Accept": "application/json" }
        })
            .then(r => r.json())
            .then(data => {
                this.resultsTarget.innerHTML = data.map(user => `
        <option
          value="${user.name} ${user.surname}"
          data-id="${user.id}"
          data-name="${user.name}"
          data-surname="${user.surname}"
          data-email="${user.email}"
          data-phone="${user.phone}"
        >
          ${user.name} ${user.surname} (${user.birth_day})
        </option>
      `).join("");
            });
    }

    selectUser() {
        const val = this.inputTarget.value;
        const option = Array.from(this.resultsTarget.options)
              .find(o => o.value === val);

        if (option) {
            this.hiddenUserIdTarget.value = option.dataset.id;
            this.nameTarget.value    = option.dataset.name;
            this.surnameTarget.value = option.dataset.surname;
            this.emailTarget.value   = option.dataset.email;
            this.phoneTarget.value   = option.dataset.phone;
        } else {
            resetUserFields();
        }
    }

    resetUserFields() {
        this.hiddenUserIdTarget.value = ""
        this.nameTarget.value    = ""
        this.surnameTarget.value = ""
        this.emailTarget.value   = ""
        this.phoneTarget.value   = ""
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
