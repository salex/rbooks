import { Controller } from "stimulus"
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = []

  connect() {
    // dates are input objects, not value
    // console.log("reports picker connected")
  }

  selectAuditPDF(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }

  selectButtonURL(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }


  selectAuditConfig(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }
  selectAuditHTML(){
    const button = event.target
    var url = button.dataset.url
    location.assign(url)
  }


}