(********************************************************************************)
(*	Common.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type ('a, 'b) result_t = [ `Okay of 'a | `Error of 'b ]


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let (!!) = Lazy.force

let maybe f = function
	| Some x -> Some (f x)
	| None	 -> None

let lwt_may f = function
	| Some x -> f x
	| None	 -> Lwt.return ()
