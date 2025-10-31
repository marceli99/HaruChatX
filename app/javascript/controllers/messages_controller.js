import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "form", "sendButton"]

    connect() {
        this.formTarget.addEventListener("submit", this.disableSendButton.bind(this));
    }

    disableSendButton() {
        this.sendButtonTarget.disabled = true
    }
}
