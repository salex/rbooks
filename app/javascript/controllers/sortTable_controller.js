// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ ]

  connect() {
  // console.log('Hello, sortTable!')
    this.numeric = false
  }

  sortBy(){
    const th = event.target
    this.numeric = th.classList.contains('numeric')
    const tr = th.closest('tr')
    const table = tr.closest('table')
    var idx = Array.from(tr.children).indexOf(th)
    var skip = 1
    this.sortTable(table,idx)
  }

  sortTable(table,n,thCount) {
    var  rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
    switching = true;
    // Set the sorting direction to ascending:
    dir = "asc"; 
    /* Make a loop that will continue until
    no switching has been done: */

    while (switching) {
      // Start by saying: no switching is done:
      switching = false;
      rows = table.rows;
      /* Loop through all table rows (except the
      first, which contains table headers): */

      for (i = 1; i < (rows.length - 1); i++) {
        // Start by saying there should be no switching:
        shouldSwitch = false;
        /* Get the two elements you want to compare,
        one from current row and one from the next: */

        x = rows[i].getElementsByTagName("TD")[n];
        y = rows[i + 1].getElementsByTagName("TD")[n];
        // Added this check if there is a row that has a colspan e.g. ending balance row
        if ((x == undefined) || (y == undefined)){continue}
        /* Check if the two rows should switch place,
        based on the direction, asc or desc: */

        // Check if numeric sort (th has class numeric)
        if (!this.numeric) {
          var compx = x.innerHTML.toLowerCase()
          var compy = y.innerHTML.toLowerCase()
        }else{
          var compx = /\d/.test(x.innerHTML) ? parseFloat(x.innerHTML) : 0 
          var compy = /\d/.test(y.innerHTML) ? parseFloat(y.innerHTML) : 0 
        }
        
        if (dir == "asc") {
          if (compx > compy) {
            // If so, mark as a switch and break the loop:
            shouldSwitch = true;
            break;
          }
        } else if (dir == "desc") {
          if (compx < compy) {
            // If so, mark as a switch and break the loop:
            shouldSwitch = true;
            break;
          }
        }
      }
      if (shouldSwitch) {
        /* If a switch has been marked, make the switch
        and mark that a switch has been done: */
        rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
        switching = true;
        // Each time a switch is done, increase this count by 1:
        switchcount ++; 
      } else {
        /* If no switching has been done AND the direction is "asc",
        set the direction to "desc" and run the while loop again. */
        if (switchcount == 0 && dir == "asc") {
          dir = "desc";
          switching = true;
        }
      }
    }
  }

}
