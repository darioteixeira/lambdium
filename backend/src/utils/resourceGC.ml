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

type pool_t =
	{
	name: string;
	buffer: int array;
	cleaners: cleaner_t array;
	passwords: string array;
	last_used: float array;
	max_age: float;
	size: int;
	ptr: int ref;
	}


(********************************************************************************)
(**	{1 Functions and values}						*)
(********************************************************************************)

let nop () = ()


let id x = x


let get_token pool cleaner =
	if !(pool.ptr) > 0
	then begin
		decr (pool.ptr);
		let now = Unix.gettimeofday () in
		let token_ptr = pool.buffer.(!(pool.ptr))
		and token_pass = Printf.sprintf "%lx%lx" (Random.int32 Int32.max_int) (Int32.bits_of_float now) in
		pool.cleaners.(token_ptr) <- cleaner;
		pool.passwords.(token_ptr) <- token_pass;
		pool.last_used.(token_ptr) <- now;
		(token_ptr, token_pass)
	end else
		raise Token_unavailable


let put_token pool (token_ptr, token_pass) =
	if (!(pool.ptr) < pool.size) && (pool.passwords.(token_ptr) = token_pass)
	then begin
		pool.buffer.(!(pool.ptr)) <- token_ptr;
		pool.cleaners.(token_ptr) <- nop;
		pool.passwords.(token_ptr) <- "";
		incr (pool.ptr)
	end else
		(* This case should only happen if there is an application error. *)
		failwith "ResourceGC.put_token"


let refresh_token pool (token_ptr, token_pass) =
	if pool.passwords.(token_ptr) = token_pass
	then
		pool.last_used.(token_ptr) <- Unix.gettimeofday ()
	else
		(* This case should only happen if there is an application error. *)
		failwith "ResourceGC.refresh_token"


let rec watcher pool () =
	Ocsigen_messages.warning (Printf.sprintf "Watching '%s' pool:" pool.name);
	let now = Unix.gettimeofday () in
	let candidates = Array.sub pool.buffer !(pool.ptr) (pool.size - !(pool.ptr)) in
	let collect token_ptr =
		if (now -. pool.last_used.(token_ptr)) > pool.max_age
		then begin
			Ocsigen_messages.warning (Printf.sprintf "\tGarbage-collecting token %d" token_ptr);
			pool.cleaners.(token_ptr) ();
			put_token pool (token_ptr, pool.passwords.(token_ptr))
		end else
			Ocsigen_messages.warning (Printf.sprintf "\tToken %d not garbage-collected" token_ptr) in
	Array.iter collect candidates;
	Lwt_timeout.start (Lwt_timeout.create 1 (watcher pool))


let make_pool name size max_age =
	let pool =
		{
		name = name;
		buffer = Array.init size id;
		cleaners = Array.make size nop;
		passwords = Array.make size "";
		last_used = Array.make size 0.0;
		max_age = max_age;
		size = size;
		ptr = ref size;
		}
	in watcher pool (); pool

