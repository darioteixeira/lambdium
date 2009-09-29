(********************************************************************************)
(*	ResourceGC.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Token_unavailable


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type cleaner_t = unit -> unit

type token_t = int * string

type pool_entry_t =
	{
	mutable back_ptr: int;
	cleaner: cleaner_t;
	password: string;
	timeout: float;
	mutable age: float;
	}

type pool_t =
	{
	name: string;
	size: int;
	default_timeout: float;
	mutable index: int;
	pointers: int array;
	entries: pool_entry_t array;
	}


(********************************************************************************)
(**	{1 Functions and values}						*)
(********************************************************************************)

(**	A no-operation function.  This is the default cleaner.
*)
let nop () = ()


(**	The ID function.
*)
let id x = x


(**	A dummy entry.
*)
let dummy_entry = {back_ptr = -1; cleaner = nop; password = ""; timeout = 0.0; age = 0.0;}


(**	Function [get_token ?timeout pool cleaner] gets a new token from [pool],
	if one is available.  You must also provide the cleaner function that will
	be invoked if the token is not refreshed nor returned for a period larger
	than either [timeout] (if specified), or the default timeout for the pool.
	Raises {!Token_unavailable} if the pool has no available tokens.
*)
let get_token ?timeout pool cleaner =
	if pool.index > 0
	then begin
		pool.index <- pool.index - 1;
		let now = Unix.gettimeofday () in
		let timeout = Option.default pool.default_timeout timeout in
		let token_idx = pool.pointers.(pool.index)
		and token_pass = Printf.sprintf "%lx%lx" (Random.int32 Int32.max_int) (Int32.bits_of_float now) in
		pool.entries.(token_idx) <- {back_ptr = pool.index; cleaner = cleaner; password = token_pass; timeout = timeout; age = now};
		(token_idx, token_pass)
	end else
		raise Token_unavailable


(**	Returns a token to the pool.  The client may not use it again.
*)
let put_token pool (token_idx, token_pass) =
	if (pool.index < pool.size) && (pool.entries.(token_idx).password = token_pass)
	then begin
		let old_idx = pool.pointers.(pool.index) in
		pool.pointers.(pool.index) <- token_idx;
		pool.pointers.(pool.entries.(token_idx).back_ptr) <- old_idx;
		pool.entries.(old_idx).back_ptr <- pool.entries.(token_idx).back_ptr;
		pool.entries.(token_idx) <- dummy_entry;
		pool.index <- pool.index + 1;
	end else
		(* This case should only happen if there is an application error. *)
		failwith "ResourceGC.put_token"


(**	Refreshes the age of a previously retrieved token.
*)
let refresh_token pool (token_idx, token_pass) =
	if pool.entries.(token_idx).password = token_pass
	then
		pool.entries.(token_idx).age <- Unix.gettimeofday ()
	else
		(* This case should only happen if there is an application error. *)
		failwith "ResourceGC.refresh_token"


(**	The watcher function wakes up periodically, checking if any of the outstanding
	tokens has an age greater than allowed.  Those that do are forcibly returned to
	the pool, and the corresponding cleaner function is invoked.
*)
let rec watcher pool () =
	Ocsigen_messages.warning (Printf.sprintf "Watching '%s' pool:" pool.name);
	let now = Unix.gettimeofday () in
	let candidates = Array.sub pool.pointers pool.index (pool.size - pool.index) in
	let collect token_idx =
		if (now -. pool.entries.(token_idx).age) > pool.entries.(token_idx).timeout
		then begin
			Ocsigen_messages.warning (Printf.sprintf "\tGarbage-collecting token %d" token_idx);
			pool.entries.(token_idx).cleaner ();
			put_token pool (token_idx, pool.entries.(token_idx).password)
		end else
			Ocsigen_messages.warning (Printf.sprintf "\tToken %d not garbage-collected" token_idx) in
	Array.iter collect candidates;
	Lwt_timeout.start (Lwt_timeout.create 1 (watcher pool))


(**	An invocation of [make_pool name size timeout] creates a new pool with the given
	name and size, and whose tokens may be unrefreshed for a default maximum time of
	[timeout] before they are forcibly returned to the pool.
*)
let make_pool name size default_timeout =
	let pool =
		{
		name = name;
		size = size;
		default_timeout = default_timeout;
		index = size;
		pointers = Array.init size id;
		entries = Array.make size dummy_entry;
		}
	in watcher pool (); pool

