import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static values = { messageId: String, autoscroll: { type: Boolean, default: true } }

  static loader = `<div class="loader"></div>`

  connect() {
    this.raf = null

    this.subscription = consumer.subscriptions.create(
      { channel: "MessageChannel", id: this.messageIdValue },
      { received: (data) => this.received(data) }
    )

    this.scrollContainer = this.element.hasAttribute("data-scroll-container") 
      ? this.element 
      : this.element.closest("[data-scroll-container]")
  }

  received(data) {
    if(this.element.textContent == this.constructor.loader) this.element.textContent = ""

    if (data.type === "chunk") {
      this.element.textContent += data.content
      if (!this.raf) this.raf = requestAnimationFrame(() => this.flush())
    } else if (data.type === "done") {
      this.flush()
      this.teardown()
    } else if (data.type === "error") {
      this.element.textContent += `\nError: ${data.message}`
      if (!this.raf) this.raf = requestAnimationFrame(() => this.flush())
      this.teardown()
    }
  }

  flush() {
    this.raf = null
    this.stickToBottomIfNeeded()
  }

  userNearBottom() {
    const c = this.scrollContainer
    const el = c || document.documentElement
    const scrollTop = c ? c.scrollTop : document.documentElement.scrollTop || document.body.scrollTop
    const clientH   = c ? c.clientHeight : window.innerHeight
    const remaining = el.scrollHeight - scrollTop - clientH
    return remaining < 48
  }

  stickToBottomIfNeeded() {
    if (!this.autoscrollValue) return
    if (!this.scrollContainer && this.userNearBottom()) window.scrollTo({ top: document.documentElement.scrollHeight })
    if (this.scrollContainer && this.userNearBottom()) this.scrollContainer.scrollTop = this.scrollContainer.scrollHeight
  }

  disconnect() { this.teardown() }
  teardown() {
    this.subscription?.unsubscribe()
    if (this.raf) cancelAnimationFrame(this.raf)
    this.subscription = null
    this.raf = null
  }
}
