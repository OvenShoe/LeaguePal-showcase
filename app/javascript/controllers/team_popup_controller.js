import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    token: String,
    acceptUrl: String,
    rejectUrl: String,
    teamName: String
  }

  connect() {
    console.log("TeamPopupController connected")
  }

  acceptInvitation(e) {
    e.preventDefault()
    this.submitInvitationResponse(this.acceptUrlValue)
  }

  rejectInvitation(e) {
    e.preventDefault()
    this.submitInvitationResponse(this.rejectUrlValue)
  }

  submitInvitationResponse(url) {
    fetch(url, {
      method: "POST",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCsrfToken()
      },
      body: JSON.stringify({ token: this.tokenValue })
    })
    .then(response => response.json().then(data => ({ status: response.status, data })))
    .then(({ status, data }) => {
      if (status >= 200 && status < 300) {
        // Success - redirect
        if (data.redirect_url) {
          window.location.href = data.redirect_url
        } else {
          window.location.reload()
        }
      } else {
        // Error - show message and reload or stay
        console.error("Failed to process invitation:", data.error)
        let errorMessage = data.error || "An error occurred while processing your invitation"
        alert(errorMessage)
        window.location.reload()
      }
    })
    .catch(error => {
      console.error("Error:", error)
      alert("An error occurred. Please try again.")
    })
  }

  getCsrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}