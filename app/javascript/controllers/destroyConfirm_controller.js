import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "submit"]
  static values = { cmsg: String}

  connect() {
    // console.log("destroy confirm")
    if (this.hasCmsgValue) {
      this.confirm_msg = this.cmsgValue
    }else{
      this.confirm_msg  = "Are you sure?"
    }
  }

  confirm(){
    // console.log(this.submitTarget.closest('form'))
    let ans = confirm(`${this.confirm_msg}`)
    if (ans == true) {
      this.submitTarget.closest('form').submit()
    }
  }

}
