// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./controllers"

import "@rails/actiontext"
import "trix"

// Add this to a new JavaScript file or to your application.js

// Listen for Turbo Frame events
document.addEventListener('turbo:frame-load', function (event) {
  // Only handle email_content frame loads
  if (event.target.id === 'email_content') {
    // Update active state in email list
    updateActiveEmailInList();

    // Scroll the email content to the top
    event.target.scrollTo(0, 0);
  }
});

// Update which email is active in the list
function updateActiveEmailInList() {
  // Get the current email ID from the URL in the frame
  const emailContentFrame = document.getElementById('email_content');
  const currentUrl = emailContentFrame.querySelector('form')?.action ||
    emailContentFrame.querySelector('a[href*="/emails/"]')?.href;

  if (!currentUrl) return;

  // Extract the ID from the URL
  const match = currentUrl.match(/\/emails\/(\d+)/);
  if (!match) return;

  const currentEmailId = match[1];

  // Remove active class from all emails
  document.querySelectorAll('.email-list-item').forEach(item => {
    item.classList.remove('active');
  });

  // Add active class to current email
  const activeItem = document.querySelector(`.email-list-item[data-email-id="${currentEmailId}"]`);
  if (activeItem) {
    activeItem.classList.add('active');

    // Scroll into view if needed
    const listContainer = activeItem.closest('.split-view-list');
    if (listContainer && !isElementInViewport(activeItem, listContainer)) {
      activeItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
  }
}

// Helper to check if an element is in viewport
function isElementInViewport(el, container) {
  const rect = el.getBoundingClientRect();
  const containerRect = container.getBoundingClientRect();

  return (
    rect.top >= containerRect.top &&
    rect.left >= containerRect.left &&
    rect.bottom <= containerRect.bottom &&
    rect.right <= containerRect.right
  );
}

// Add loading state to frames
document.addEventListener('turbo:frame-loading', function (event) {
  if (event.target.id === 'email_content') {
    event.target.classList.add('loading');
  }
});

document.addEventListener('turbo:frame-load', function (event) {
  if (event.target.id === 'email_content') {
    event.target.classList.remove('loading');
  }
});

// Handle mobile view toggle
document.addEventListener('DOMContentLoaded', function () {
  const mobileViewToggle = document.querySelector('.mobile-view-toggle');

  if (mobileViewToggle) {
    mobileViewToggle.addEventListener('click', function () {
      const splitView = document.querySelector('.split-view');
      splitView.classList.toggle('mobile-list-view');
      splitView.classList.toggle('mobile-content-view');
    });
  }
});
