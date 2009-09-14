(********************************************************************************)
(*	Database.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.	
*)
(********************************************************************************)

(**	The database module provides a high-level API for data storage.
	It uses the PG'OCaml syntax extension, and therefore relies on
	a PostgreSQL backend for the actual storage of data.

	Note that because database access is inherently a time-consuming
	operation, but one where we simply wait for input, all functions
	in this module are meant to be used with Lwt cooperative threads.
	They therefore return 'a Lwt.t.
*)

(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Cannot_get_timezone
exception Cannot_get_user
exception Cannot_get_login
exception Cannot_get_story
exception Cannot_get_comment

exception Cannot_add_user
exception Cannot_add_story
exception Cannot_add_comment

exception Cannot_edit_user_credentials
exception Cannot_edit_user_settings
exception Cannot_get_nick_availability


(********************************************************************************)
(**	{1 Public functions and values}						*)
(********************************************************************************)

(********************************************************************************)
(**	{2 Functions returning timezones}					*)
(********************************************************************************)

val get_timezones: unit -> Timezone.full_t list Lwt.t
val get_timezone: Timezone.Id.t option -> Timezone.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning users}						*)
(********************************************************************************)

val get_users: unit -> User.handle_t list Lwt.t
val get_user: User.Id.t -> User.full_t Lwt.t
val get_login: string -> string -> Login.t Lwt.t


(********************************************************************************)
(**	{2 Functions returning stories}						*)
(********************************************************************************)

val get_stories: Login.t option -> Story.blurb_t list Lwt.t
val get_user_stories: User.Id.t -> Story.handle_t list Lwt.t
val get_story: Login.t option -> Story.Id.t -> Story.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning comments}					*)
(********************************************************************************)

val get_story_comments: Login.t option -> Story.Id.t -> Comment.full_t list Lwt.t
val get_user_comments: User.Id.t -> Comment.handle_t list Lwt.t
val get_comment: Login.t option -> Comment.Id.t -> Comment.full_t Lwt.t


(********************************************************************************)
(**	{2 Functions returning mixed content (this AND that)}			*)
(********************************************************************************)

(**	Note: the reason why these special functions should be used (instead of
	simply calling the individual functions separately) is to ensure that we
	get a consistent snapshot of the database at a point in time.  Note that
	we use the transaction mechanisms (PGOCaml.begin_work et al) for that.
*)

val get_story_with_comments: Login.t option -> Story.Id.t -> (Story.full_t * Comment.full_t list) Lwt.t


(********************************************************************************)
(**	{2 Functions that add content to the database}				*)
(********************************************************************************)

val add_user: User.fresh_t -> unit Lwt.t
val add_story: Story.fresh_t -> unit Lwt.t
val add_comment: Comment.fresh_t -> unit Lwt.t


(********************************************************************************)
(**	{2 Functions that edit content from the database}			*)
(********************************************************************************)

val edit_user_credentials: User.changed_credentials_t -> unit Lwt.t
val edit_user_settings: User.changed_settings_t -> unit Lwt.t


(********************************************************************************)
(**	{2 Functions that return the availability of a given element}		*)
(********************************************************************************)

val is_available_nick: string -> bool Lwt.t

