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

open Unix
open ExtString
open Simplexmlparser


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type login_table_t =
	| Use_volatile
	| Use_persistent


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let login_table_of_string = function
	| "volatile"	-> Use_volatile
	| "persistent"	-> Use_persistent
	| x		-> raise (Ocsigen_extensions.Error_in_config_file ("Unknown 'logintable' value: " ^ x))


let sockdomain_of_string = function
	| "unix"  -> PF_UNIX
	| "inet"  -> PF_INET
	| "inet6" -> PF_INET6
	| x	  -> raise (Ocsigen_extensions.Error_in_config_file ("Unknown 'sockdomain' value: " ^ x))


let socktype_of_string = function
	| "stream"    -> SOCK_STREAM
	| "dgram"     -> SOCK_DGRAM
	| "raw"	      -> SOCK_RAW
	| "seqpacket" -> SOCK_SEQPACKET
	| x	      -> raise (Ocsigen_extensions.Error_in_config_file ("Unknown 'socktype' value: " ^ x))


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let login_table = ref Use_persistent

let static_dir = ref "static"
let story_dir = ref "sdata"
let comment_dir = ref "cdata"
let limbo_dir = ref "limbo"
let global_upload_limit = ref 20

let pghost = ref None
let pgport = ref None
let pguser = ref None
let pgpassword = ref None
let pgdatabase = ref None
let pgsocketdir = ref None

let sockaddr = ref (ADDR_INET (inet_addr_loopback, 9999))
let sockdomain = ref PF_INET
let socktype= ref SOCK_STREAM
let sockproto = ref 0


let parse_config () =
	let parse_pgocaml = function
		| Element ("pghost", [], [PCData s]) ->
			pghost := Some s
		| Element ("pgport", [], [PCData s]) ->
			pgport := Some (int_of_string s)
		| Element ("pguser", [], [PCData s]) ->
			pguser := Some s
		| Element ("pgpassword", [], [PCData s]) ->
			pgpassword := Some s
		| Element ("pgdatabase", [], [PCData s]) ->
			pgdatabase := Some s
		| Element ("pgsocketdir", [], [PCData s]) ->
			pgsocketdir := Some s
		| _ ->
			raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'pgocaml'") in
	let parse_parserver = function
		| Element ("sockaddr", [("type", "unix")], [PCData s]) ->
			sockaddr := ADDR_UNIX s
		| Element ("sockaddr", [("type", "inet")], [PCData s]) ->
			let (host, port) = String.split s ":"
			in sockaddr := ADDR_INET (inet_addr_of_string host, int_of_string port)
		| Element ("sockaddr", _, [PCData s]) ->
			raise (Ocsigen_extensions.Error_in_config_file "Error in 'sockaddr' specification")
		| Element ("sockdomain", [], [PCData s]) ->
			sockdomain := sockdomain_of_string s
		| Element ("socktype", [], [PCData s]) ->
			socktype := socktype_of_string s
		| Element ("sockproto", [], [PCData s]) ->
			sockproto := int_of_string s
		| _ ->
			raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'parserver'") in
	let parse_top = function
		| Element ("logintable", [], [PCData s]) ->
			login_table := login_table_of_string s
		| Element ("staticdir", [], [PCData s]) ->
			static_dir := s
		| Element ("storydir", [], [PCData s]) ->
			story_dir := s
		| Element ("commentdir", [], [PCData s]) ->
			comment_dir := s
		| Element ("limbodir", [], [PCData s]) ->
			limbo_dir := s
		| Element ("globaluploadlimit", [], [PCData s])	->
			global_upload_limit := int_of_string s
		| Element ("pgocaml", [], children) ->
			List.iter parse_pgocaml children
		| Element ("parserver", [], children) ->
			List.iter parse_parserver children
		| _ ->
			raise (Ocsigen_extensions.Error_in_config_file "Unknown element under 'lambdium'") in
	let config = Eliom_sessions.get_config ()
	in List.iter parse_top config

