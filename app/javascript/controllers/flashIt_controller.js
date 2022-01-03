import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "flashBox" ]

  connect() {
    this.closeFlashIt()
    console.log('flashit1')
  }

  closeFlashIt(){
    var box = this.flashBoxTarget
    console.log('flashit2')

    setTimeout(function () {
      // box.style.display = 'none'

      var op = 1;  // initial opacity
        var timer = setInterval(function () {
            if (op <= 0.1){
                clearInterval(timer);
                box.style.display = 'none';
            }
            box.style.opacity = op;
            box.style.filter = 'alpha(opacity=' + op * 100 + ")";
            op -= op * 0.1;
        }, 100);

    }, 5000);
  }
}
