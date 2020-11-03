
import { Controller } from "stimulus"
import Rails from '@rails/ujs';

export default class extends Controller {
  static targets = [ 'refresh','closing_date','closing_balance']

  connect() {
    // console.log("opened remote update")
  }

  rebalance(){
    const bal = this.closing_balanceTarget.value
    const date = this.closing_dateTarget.value
    location.assign(`/reports/checking_balance?closing_date=${date}&closing_balance=${bal}`)
  }

  onSuccess(event) {
    console.log("twas called")
    let [data, status, xhr] = event.detail;
    this.refreshTarget.innerHTML = xhr.response;
  }
}
