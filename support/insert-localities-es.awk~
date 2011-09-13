BEGIN { 
  FS=","; ORS="\n" 
} 
function titlecase(string)  {
  # Initialize variables
  a = "";            # a is/will be the string ALREADY converted
  b = string;        # b is the rest of the string, so that (string = a b)

  b = toupper(b)     # Capitalize everything for ease of matching

  do {
    hit = 0;         # Initialize for later use

    pos = match(b, /[^A-Z'-]+/)

    if (pos > 0)    word = substr(b, 1, pos + RLENGTH - 1)
    else            word = b

    # 1st char of current word
    head = substr(b, 1, 1)

    # tail of current word
    if (pos > 0)    tail = substr(b, 2, pos + RLENGTH - 2)
    else            tail = substr(b, 2)

    # shorten the rest of the string
    b = substr(b, pos + RLENGTH  )


    #----Words to be set in MiXed case----
    # Case 3: Names like D'Arcy or O'Reilly
    if ( hit == 0 && match(word, /^[DO]'[A-Z]/) ) {
       if (debug) print "DIAG: Match on mixed case: " word
       word = substr(word,1,3) tolower(substr(word,4))
       hit = 1
    }

    # Case 4: Names like McDonald
    if ( hit == 0 && match(word,/^MC[A-Z]/) ) {
      word = substr(word,1,1) tolower(substr(word,2,1)) \
             substr(word,3,1) tolower(substr(word,4))
      hit = 1
    }

    #----Default: Capitalize everything else normally----
    if (hit > 0)    a = a word
    else            a = a toupper(head) tolower(tail)

  } while (pos > 0);

  # Everything should be converted now.
  return a
}

{ 
  if ($10 ~ "\"Delivery Area.*\"" && $4 !~ "\"PO.*") {
    print "db.localities.insert({\"postcode\":"$1", \"locality\":\""titlecase(substr($2,2,length($2)-2))"\", \"state\":"$3", \"zone\":"$7"})"
  }
}
