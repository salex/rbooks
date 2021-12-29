
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "numb","last_numbers"]

  connect() {
    this.json = this.getJSON()

  }

  keyDown(){
    const e = event
    const numb = event.target
    if ((e.which !== 187) && (e.which !== 189)){
      return
    } else {
      event.preventDefault()
      // stop equal minus from displaying
      let adder, key, ltr, num;
      if (e.which === 187) {
        adder = 1;
      } else {
        adder = -1;
      }

        // console.log(json)
      if (numb.value === '') {
        key = 'numb';
        ltr = '';
        num = '';
      } else {
        const val = numb.value;
        ltr = val.replace(/\d+/,'');
        num = val.replace(/\D+/,'');
        if (num === '') {
          key = ltr;
        } else {
          numb.value = ltr + (Number(num) + adder);
          return
        }
      }

      // now have a key that has no number
      const hasKey = this.json.hasOwnProperty(key);
      // console.log( `has key ${hasKey} ${key} ${adder}`)
      if (key === 'numb') {
        numb.value = this.json[key] + adder;
      } else {
        if (hasKey) {
          const nxt = this.json[key] + adder;
          numb.value = key + nxt;
          this.json[key] = nxt;
        } else {
          this.json[key] = adder;
          numb.value = key+'1';
        }
      }
    }
  }

  getJSON(){
    const last_numbers = this.last_numbersTarget
    return(JSON.parse(last_numbers.dataset.numbers))

  }
}
