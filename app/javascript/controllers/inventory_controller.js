/* 
  Rails.root/app/javascript/controllers/inventroy-controller.js
*/
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ 'bottles',"wbottles", "cbottles","cases",'total','size','percent','ckd']

  connect() {
    this.idx
  }

  indexOfTargetInTargets(target,targets){
    var i
    for (i = 0; i < targets.length; i++) {
      if (targets[i] == target) {break}
    }
    return i
  }

  updateBeer(){
    var beer = event.target 
    const beerTarget = beer.dataset
    const beerTargets = eval(`this.${beerTarget.inventoryTarget}Targets`)
    this.idx = this.indexOfTargetInTargets(beer,beerTargets)
    // console.log(`w ${this.wbottles} c ${this.cbottles}`)
    this.bottlesTargets[this.idx].value = this.wbottles + this.cbottles
    this.totalTargets[this.idx].value = this.wbottles + this.cbottles + (this.cases * this.size )
    this.ckdTargets[this.idx].checked = true
  }

  updateLiquor(){
    var liquor =  event.target
    const liquorTarget = liquor.dataset
    const liquorTargets = eval(`this.${liquorTarget.inventoryTarget}Targets`)
    this.idx = this.indexOfTargetInTargets(liquor,liquorTargets)
    const shots = ((this.size * (this.percent / 100.0)) / 35.5)
    const bottles = ((this.bottles  * this.size) / 35.5)
    this.totalTargets[this.idx].value = Math.round(bottles + shots)
    this.ckdTargets[this.idx].checked = true
  }

  get cases(){
    return Number(this.casesTargets[this.idx].value)
  }
  get wbottles(){
    return Number(this.wbottlesTargets[this.idx].value)
  }
  get cbottles(){
    return Number(this.cbottlesTargets[this.idx].value)
  }
  get size(){
    return Number(this.sizeTargets[this.idx].value)
  }
  get bottles(){
    return Number(this.bottlesTargets[this.idx].value)
  }
  get percent(){
    return Number(this.percentTargets[this.idx].value)
  }

}

