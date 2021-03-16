// hideTarget.controller
// TODO  not used
import { Controller } from "stimulus"
import Rails from '@rails/ujs';


export default class extends Controller {
  static targets = ['reconcile']
  connect() {
    console.log('Hello reconcile')
  }

  clearSplits() {
    console.log("clear click")
    var reconcile = event.currentTarget
    var entryid =reconcile.nextElementSibling

    Rails.ajax({
      url: "/bank_statements/clear_splits.js",
      type: "patch",
      data: "entry_id="+entryid.value,
      success: function(data) {
        console.log('data');
      }
    })

  }

  unclearSplits(){
    console.log("unclear click")
    var reconcile = event.currentTarget
    var entryid =reconcile.nextElementSibling

    Rails.ajax({
      url: "/bank_statements/unclear_splits.js",
      type: "patch",
      data: "entry_id="+entryid.value,

      success: function(data) {
        console.log('data');
      }
    })

  }

}