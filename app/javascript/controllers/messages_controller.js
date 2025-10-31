import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "form", "sendButton"]

    connect() {
        this.sendButtonTarget.addEventListener("click", this.disableSendButton.bind(this));
    }

    disableSendButton() {
        this.sendButtonTarget.disabled = true
    }
}
