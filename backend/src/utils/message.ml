(********************************************************************************)
(*	Message.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open XHTML.M


(********************************************************************************)
(*	{1 Public functions and values}						*)
(********************************************************************************)

let error msg = p ~a:[a_class ["error_msg"]] [pcdata msg]

