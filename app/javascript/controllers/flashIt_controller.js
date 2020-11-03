import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "flashBox" ]

  connect() {
    this.closeFlashIt()
    console.log('flashit')
  }

  closeFlashIt(){
    var box = this.flashBoxTarget
    console.log('flashit')
    setTimeout(function () {
      box.style.display = 'none'
    }, 10000);
  }
}
