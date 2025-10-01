import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.element.addEventListener('play-dong', () => this.playDong());
    // Optionally expose controller for direct access
    this.element.controller = this;
  }

  playDong() {
    const audio = new Audio("/dong.mp3");
    audio.play();
  }
}
