import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

connect() {
    this.element.addEventListener('play-dong', () => this.playDong());
    this.element.controller = this;

    let messagesContainer = this.element.querySelector('section, div, ul');
    if (!messagesContainer) messagesContainer = this.element;

    this.observer = new MutationObserver((mutationsList) => {
      for (const mutation of mutationsList) {
        for (const node of mutation.addedNodes) {
          if (node.nodeType === 1 && node.classList.contains('assistant-message')) {
            this.playDong();
          }
        }
      }
    });
    this.observer.observe(messagesContainer, { childList: true });
  }

  playDong() {
    // const audio = new Audio("/dong.mp3");
    // audio.play();
  }
}
