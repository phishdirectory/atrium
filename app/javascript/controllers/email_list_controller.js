// app/javascript/controllers/email_list_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "content", "item"]

  connect() {
    console.log("Email list controller connected")
    // Mark the first email as active by default if none is selected
    if (this.hasItemTarget && !this.activeItem) {
      this.itemTargets[0]?.classList.add("active")
    }

    // Watch for frame updates
    this.observeFrameLoads()
  }

  // Handle selecting an email in the list
  select(event) {
    // Allow the link to handle the click if it's the target
    if (event.target.tagName === 'A' ||
      event.target.closest('a') ||
      event.target.tagName === 'BUTTON') {
      return
    }

    // Prevent the default behavior to avoid full page navigation
    event.preventDefault()

    const item = event.currentTarget

    // Find the link inside this item and trigger it
    const link = item.querySelector('a[data-turbo-frame="email_content"]')
    if (link) {
      link.click()
    }

    // Update active state
    this.itemTargets.forEach(el => {
      el.classList.remove("active")
    })

    item.classList.add("active")

    // On mobile, show the content panel
    if (window.innerWidth < 768) {
      this.showContentPanel()
    }
  }

  // Monitor frame loads to update UI accordingly
  observeFrameLoads() {
    document.addEventListener('turbo:frame-load', (event) => {
      if (event.target.id === 'email_content') {
        this.updateActiveState()
      }
    })
  }

  // Update which email is active based on the current content
  updateActiveState() {
    // Find the current email ID from the frame content
    const emailContentFrame = document.getElementById('email_content')
    if (!emailContentFrame) return

    // Look for data attributes, forms, or links that might contain the email ID
    const currentEmailId = this.getCurrentEmailId(emailContentFrame)
    if (!currentEmailId) return

    // Update the active state
    this.itemTargets.forEach(item => {
      const itemId = item.dataset.emailId
      if (itemId === currentEmailId) {
        item.classList.add("active")

        // Scroll into view if needed
        if (this.hasListTarget && !this.isElementInViewport(item, this.listTarget)) {
          item.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
        }
      } else {
        item.classList.remove("active")
      }
    })
  }

  // Helper to extract current email ID
  getCurrentEmailId(frame) {
    // Try to find it from data attribute
    const container = frame.querySelector('[data-email-id]')
    if (container) return container.dataset.emailId

    // Try to get it from forms
    const form = frame.querySelector('form[action*="/emails/"]')
    if (form) {
      const match = form.action.match(/\/emails\/(\d+)/)
      if (match) return match[1]
    }

    // Try to get it from links
    const link = frame.querySelector('a[href*="/emails/"]')
    if (link) {
      const match = link.href.match(/\/emails\/(\d+)/)
      if (match) return match[1]
    }

    return null
  }

  // Toggle between list and content on mobile
  showListPanel() {
    if (this.hasListTarget && this.hasContentTarget) {
      this.listTarget.classList.remove("hidden", "md:block")
      this.contentTarget.classList.add("hidden", "md:block")
    }
  }

  showContentPanel() {
    if (this.hasListTarget && this.hasContentTarget) {
      this.listTarget.classList.add("hidden", "md:block")
      this.contentTarget.classList.remove("hidden", "md:block")
    }
  }

  // Helper to check if element is in viewport
  isElementInViewport(el, container) {
    const rect = el.getBoundingClientRect()
    const containerRect = container.getBoundingClientRect()

    return (
      rect.top >= containerRect.top &&
      rect.left >= containerRect.left &&
      rect.bottom <= containerRect.bottom &&
      rect.right <= containerRect.right
    )
  }

  get activeItem() {
    return this.itemTargets.find(item => item.classList.contains("active"))
  }
}
