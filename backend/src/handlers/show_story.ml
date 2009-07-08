(********************************************************************************)
(*	Show_story.ml
        Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
        This software is distributed under the terms of the GNU GPL version 2.
        See LICENSE file for full license text.
*)
(********************************************************************************)

open Lwt


(********************************************************************************)
(**	{2 Private functions}							*)
(********************************************************************************)

let output_canvas sid maybe_login sp =
	Lwt.catch
		(fun () ->
			Database.get_story_with_comments maybe_login sid >>= fun (story, comments) ->
			Canvas.custom [Story_output.output_full maybe_login sp story comments])
		(function
			| Database.Cannot_get_story	-> Canvas.failure "Cannot find specified story!"
			| exc				-> Lwt.fail exc)


(********************************************************************************)
(**	{2 Public functions}							*)
(********************************************************************************)

let handler sp sid () =
	Page.standard_handler
		~sp	
		~page_title: "Show Story"
		~canvas_maker: (output_canvas sid)

