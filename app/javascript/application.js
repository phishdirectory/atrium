// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "./controllers"

import "@rails/actiontext"
import "trix"

// Listen for Turbo Frame events
document.addEventListener('turbo:frame-load', function (event) {
  // Only handle email_content frame loads
  if (event.target.id === 'email_content') {
    // Scroll the email content to the top
    event.target.scrollTo(0, 0);
  }
});

// Make sure form submissions update correctly
document.addEventListener('turbo:before-fetch-request', function (event) {
  // For form submissions from email actions (star, archive, etc.)
  if (event.target.tagName === 'FORM' &&
    (event.target.action.includes('/star') ||
      event.target.action.includes('/unstar') ||
      event.target.action.includes('/archive') ||
      event.target.action.includes('/unarchive'))) {

    // Add a callback for when the request succeeds
    event.detail.fetchOptions.success = function () {
      // Reload the email list to show updated state
      const emailList = document.querySelector('.split-view-list');
      if (emailList) {
        Turbo.visit(window.location.href, { action: 'replace' });
      }
    };
  }
});

// Handle mobile view toggle
document.addEventListener('DOMContentLoaded', function () {
  const mobileViewToggle = document.querySelector('.mobile-view-toggle');
  const splitViewList = document.querySelector('.split-view-list');
  const splitViewContent = document.querySelector('.split-view-content');

  if (mobileViewToggle && splitViewList && splitViewContent) {
    mobileViewToggle.addEventListener('click', function () {
      // Toggle between list and content views on mobile
      if (splitViewList.classList.contains('hidden')) {
        // Currently showing content, switch to list
        splitViewList.classList.remove('hidden');
        splitViewContent.classList.add('hidden');
      } else {
        // Currently showing list, switch to content
        splitViewList.classList.add('hidden');
        splitViewContent.classList.remove('hidden');
      }
    });
  }

  // Mark email as read when viewing it
  const emailContentFrame = document.getElementById('email_content');
  if (emailContentFrame) {
    emailContentFrame.addEventListener('turbo:frame-load', function () {
      // Find the current active email in the list
      const activeEmail = document.querySelector('.email-list-item.active');
      if (activeEmail) {
        // Remove the unread styling (blue background)
        activeEmail.classList.remove('bg-blue-50');
        activeEmail.classList.add('bg-white');
      }
    });
  }
});
