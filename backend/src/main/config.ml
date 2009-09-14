(********************************************************************************)
(*	Config.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	This module takes care of configuring Lambdium.  The configuration is
	read from the ocsigen.conf file (or equivalent passed as parameter to
	the executable).
*)

open Simplexmlparser


(********************************************************************************)
(*	{1 Public functions and values}						*)
(********************************************************************************)

let pghost = ref None
let pgport = ref None
let pguser = ref None
let pgpassword = ref None
let pgdatabase = ref None
let pgsocketdir = ref None


let parse_config () =
	let parse_pgocaml = function
		| Element ("pghost", [], [PCData s])	  -> pghost := Some s
		| Element ("pgport", [], [PCData s])	  -> pgport := Some (int_of_string s)
		| Element ("pguser", [], [PCData s])	  -> pguser := Some s
		| Element ("pgpassword", [], [PCData s])  -> pgpassword := Some s
		| Element ("pgdatabase", [], [PCData s])  -> pgdatabase := Some s
		| Element ("pgsocketdir", [], [PCData s]) -> pgsocketdir := Some s
		| _					  -> failwith "parse_pgocaml" in
	let parse_top = function
		| Element ("pgocaml", [], children)	  -> List.iter parse_pgocaml children
		| _					  -> failwith "parse_top" in
	let config = Eliom_sessions.get_config ()
	in List.iter parse_top config

