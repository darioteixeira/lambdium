(********************************************************************************)
(*	Show_story.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt
open XHTML.M
open Page


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output_core sid maybe_login sp =
	try_lwt
		Database.get_story_with_comments sid >>= fun (story, comments) ->
		Lwt.return (Stat_nothing, Some [Story_io.output_full maybe_login sp story comments])
	with
		| Database.Cannot_get_story -> Lwt.return (Stat_failure [p [pcdata "Cannot find specified story!"]], None)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp sid () =
	Page.login_agnostic_handler
		~sp	
		~page_title: "Show Story"
		~output_core: (output_core sid)
		()

