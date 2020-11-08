test entry form/ledger validation

  The Entry ledger has two parts
    Entry - only date, number, description
    Splits - at least two

  Each split has several stats stored in a JS object and a few that are transitions states

  Four elements are used in validation
    Account - The Entry account
    Debit - a split attribute not stored in DB, used to compute amount (fixed number(2))
    Credit - a split attribute not stored in DB, used to compute amount
    Amount - amount stored in DB as pennies

    Debit and Credit are considered together as one state
      Can be only a credit or debit
      Both can be entered in a transitional state and difference computed and store in as on or the other

    With three logical conditions there are eight possible states

   
      acct zero     YYYYNNNN
      db-cr zero    YYNNYYNN
      amt zero      YNYNYNYN
      -------
      action1       x           valid - is_blank 3rd choice for imbalance
      action2        x          invalid transition error - amount set from db-cr
      action3         x         valid - is_incomplete spit valid but entry invalid - 1st choice for imbalance
      action4          x        invalid transition error - amount set to 0 (remove acct will trigger state)
      action5           x       valid - is_db_cr
      action6            x      t
      action7             x     q
      action8              x    valid

      if acct == 0 and db-cr == 0 && amt == 0   is_blank valid split valid entry
      if acct == 0 and db-cr == 0 && amt != 0   transition error amt set to zero (clear acct will trigger)
      if acct == 0 and db-cr != 0 && amt == 0   transition error amt set to db-cr and set to is_db_cr
      if acct == 0 and db-cr != 0 && amt != 0   is_scatch valid spit but error entry acct missing
      if acct != 0 and db-cr == 0 && amt == 0   is_incomplete valid, 1st choice for any imbalance
      if acct != 0 and db-cr == 0 && amt != 0   transition error, amt set to zero and made is_incomplet
      if acct != 0 and db-cr != 0 && amt == 0   transition error, set in is_db_cr
      if acct != 0 and db-cr != 0 && amt != 0   is_db_cr valid can submit


      The four is_stats is stored in object, the other transition errors are caught in setting the other states
      



  