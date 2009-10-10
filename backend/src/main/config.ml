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
(*	{1 Type definitions}							*)
(********************************************************************************)

type login_table_t =
	| Use_volatile
	| Use_persistent


(********************************************************************************)
(*	{1 Public functions and values}						*)
(********************************************************************************)

let login_table = ref Use_persistent

let story_data_dir = ref "sdata"
let comment_data_dir = ref "cdata"

let uploader_limbo_dir = ref "/tmp"
let uploader_global_capacity = ref 20
let uploader_group_capacity = ref 3
let uploader_period = ref 60

let pghost = ref None
let pgport = ref None
let pguser = ref None
let pgpassword = ref None
let pgdatabase = ref None
let pgsocketdir = ref None


let parse_config () =
	let login_table_of_string = function
		| "volatile"	-> Use_volatile
		| "persistent"	-> Use_persistent
		| s		-> raise (Ocsigen_extensions.Error_in_config_file ("Unknown 'logintable' value: " ^ s)) in
	let parse_uploader = function
		| Element ("limbodir", [], [PCData s])		-> uploader_limbo_dir := s
		| Element ("globalcapacity", [], [PCData s])	-> uploader_global_capacity := int_of_string s
		| Element ("groupcapacity", [], [PCData s])	-> uploader_group_capacity := int_of_string s
		| Element ("period", [], [PCData s])		-> uploader_period := int_of_string s
		| _						-> raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'uploader'") in
	let parse_pgocaml = function
		| Element ("pghost", [], [PCData s])		-> pghost := Some s
		| Element ("pgport", [], [PCData s])		-> pgport := Some (int_of_string s)
		| Element ("pguser", [], [PCData s])		-> pguser := Some s
		| Element ("pgpassword", [], [PCData s])	-> pgpassword := Some s
		| Element ("pgdatabase", [], [PCData s])	-> pgdatabase := Some s
		| Element ("pgsocketdir", [], [PCData s])	-> pgsocketdir := Some s
		| _						-> raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'pgocaml'") in
	let parse_top = function
		| Element ("logintable", [], [PCData s])	-> login_table := login_table_of_string s
		| Element ("storydatadir", [], [PCData s])	-> story_data_dir := s
		| Element ("commentdatadir", [], [PCData s])	-> comment_data_dir := s
		| Element ("uploader", [], children)		-> List.iter parse_uploader children
		| Element ("pgocaml", [], children)		-> List.iter parse_pgocaml children
		| _						-> raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'lambdium'") in
	let config = Eliom_sessions.get_config ()
	in List.iter parse_top config

