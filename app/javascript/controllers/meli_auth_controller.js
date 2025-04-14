import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="meli-auth"
export default class extends Controller {
  static targets = ["select", "link", "message"]

  connect() {
    this.selectTarget.addEventListener("change", this.updateLink.bind(this))
  }

  updateLink() {
    const countryDomain = this.selectTarget.value

    if (countryDomain) {
      const params = new URLSearchParams({
        client_id: this.selectTarget.dataset.clientId,
        redirect_uri: this.selectTarget.dataset.redirectUri,
        response_type: this.selectTarget.dataset.responseType
      })

      const url = `https://auth.mercadolibre.${countryDomain}/authorization?${params.toString()}`
      this.linkTarget.href = url
      this.linkTarget.classList.add("fade-in")
      this.linkTarget.style.display = "inline-block"
      this.messageTarget.classList.add("fade-in")
      this.messageTarget.style.display = "block"
    } else {
      this.linkTarget.href = "#"
      this.linkTarget.style.display = "none"
      this.messageTarget.style.display = "none"
    }
  }
}
