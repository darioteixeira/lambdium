open XHTML.M

let failure msg = p ~a:[a_class ["msg_failure"]] [pcdata msg]

let identity_failure = failure "You are not logged in!"
