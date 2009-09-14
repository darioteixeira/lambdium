(********************************************************************************)
(*	Show_story.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{1 Private functions and values}					*)
(********************************************************************************)

let output_core sid maybe_login sp =
	Lwt.catch
		(fun () ->
			Database.get_story_with_comments maybe_login sid >>= fun (story, comments) ->
			Lwt.return [Story_io.output_full maybe_login sp story comments])
		(function
			| Database.Cannot_get_story -> Lwt.return [Message.error "Cannot find specified story!"]
			| exc -> Lwt.fail exc)


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

let handler sp sid () =
	Page.login_agnostic_handler
		~sp	
		~page_title: "Show Story"
		~output_core: (output_core sid)
		()

