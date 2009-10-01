(********************************************************************************)
(*	ResourceGC.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

open ExtHashtbl


(********************************************************************************)
(**	{1 Exceptions}								*)
(********************************************************************************)

exception Global_pool_exhausted
exception Group_pool_exhausted


(********************************************************************************)
(**	{1 Type definitions}							*)
(********************************************************************************)

type cleaner_t = unit -> unit

type token_t = string option * string

type entry_t =
	{
	cleaner: cleaner_t;
	timeout: float option;
	mutable age: float;
	}

type entries_t = (string, entry_t) Hashtbl.t

type pool_t =
	{
	name: string;
	capacity: int;
	period: int;
	default_timeout: float option;
	mutable size: int;
	global: entries_t;
	groups: (string, entries_t) Hashtbl.t;
	}


(********************************************************************************)
(**	{1 Functions and values}						*)
(********************************************************************************)

(**	Function [request_token ?group ?timeout pool cleaner] gets a new token from
	[pool], if one is available.  You must also provide the cleaner function that
	will be invoked if the token is not refreshed nor returned for a period larger
	than either [timeout] (if specified), or the default timeout for the pool
	(note that if [timeout] is set to [None], then the token will never expire).
	The parameter [group] is optional, and is a pair composed of the group's name
	and its maximum number of tokens.  If this parameter is provided, the token
	is only returned if the maximum number of tokens for the group has not been
	reached.  If not present, the token is returned from the global pool.  This
	function raises {!Group_pool_exhausted} if the maximum number of tokens for
	the group is outstanding, or {!Global_pool_exhausted} if there are no available
	tokens in the global pool.
*)
let request_token ?group ?timeout pool cleaner =
	let () = match group with
		| Some (grpid, grplimit) ->
			let current = try Hashtbl.length (Hashtbl.find pool.groups grpid) with Not_found -> 0
			in if current >= grplimit then raise Group_pool_exhausted
 		| None ->
			() in
	if pool.size < pool.capacity
	then begin
		let now = Unix.gettimeofday () in
		let token_id = Printf.sprintf "%Lx%Lx" (Random.int64 Int64.max_int) (Int64.bits_of_float now) in
		let new_entry = {cleaner = cleaner; timeout = Option.default pool.default_timeout timeout; age = now;} in
		let token_grpid = match group with
			| Some (grpid, grplimit) ->
				let entries = try Hashtbl.find pool.groups grpid with Not_found -> Hashtbl.create grplimit in
				assert (not (Hashtbl.mem entries token_id));
				Hashtbl.add entries token_id new_entry;
				Hashtbl.replace pool.groups grpid entries;
				Some grpid
			| None ->
				assert (not (Hashtbl.mem pool.global token_id));
				Hashtbl.add pool.global token_id new_entry;
				None
		in
			pool.size <- pool.size + 1;
			(token_grpid, token_id)
	end else
		raise Global_pool_exhausted


(**	Returns a token to the pool.
*)
let retire_token pool (token_grpid, token_id) =
	try
		let () = match token_grpid with
			| Some grpid ->
				let entries = Hashtbl.find pool.groups grpid
				in Hashtbl.remove entries token_id;
				if Hashtbl.length entries = 0
				then Hashtbl.remove pool.groups grpid
			| None ->
				Hashtbl.remove pool.global token_id
		in pool.size <- pool.size - 1
	with
		| Not_found ->
			failwith "ResourceGC.retire_token"



(**	Refreshes the age of a previously retrieved token.
*)
let refresh_token pool (token_grpid, token_id) =
	try
		let entry = match token_grpid with
			| Some grpid -> Hashtbl.find (Hashtbl.find pool.groups grpid) token_id
			| None	     -> Hashtbl.find pool.global token_id
		in entry.age <- Unix.gettimeofday ()
	with
		| Not_found -> failwith "ResourceGC.refresh_token"


(**	The watcher function wakes up periodically, checking if any of the outstanding
	tokens has an age greater than allowed.  Those that do are forcibly returned to
	the pool, and the corresponding cleaner function is invoked.
*)
let rec watcher pool () =
	let collected = ref 0
	and uncollected = ref 0 in
	let now = Unix.gettimeofday () in
	let process token_grpid entries =
		let filter_out token_id =
			let entry = Hashtbl.find entries token_id
			in match entry.timeout with
				| Some timeout when (entry.age +. timeout) < now ->
					entry.cleaner ();
					retire_token pool (token_grpid, token_id);
					incr (collected)
				| _ ->
					incr (uncollected)
		in Enum.iter filter_out (Hashtbl.keys entries)
	in
		process None pool.global;
		Hashtbl.iter (fun grpid entries -> process (Some grpid) entries) pool.groups;
		Ocsigen_messages.warning (Printf.sprintf "Watched '%s' pool: %d tokens collected and %d untouched" pool.name !collected !uncollected);
		Lwt_timeout.start (Lwt_timeout.create pool.period (watcher pool))


(**	An invocation of [make_pool ~name ~capacity ~period ~default_timeout] creates a
	new pool with the given name and capacity, and whose tokens may be unrefreshed
	for a default maximum (approximate) time of [default_timeout] before they are
	forcibly returned to the pool.  The garbage collector runs every [period] seconds.
	Note that [default_timeout] is an optional float, and setting it to [None] means
	that by default tokens will never expire!
*)
let make_pool ~name ~capacity ~period ~default_timeout =
	let pool =
		{
		name = name;
		capacity = capacity;
		period = period;
		default_timeout = default_timeout;
		size = 0;
		global = Hashtbl.create capacity;
		groups = Hashtbl.create capacity;
		}
	in
		let msg = Printf.sprintf "Created pool '%s' with a capacity of %d, a GC period of %d, and a default timeout of %s"
			name capacity period (match default_timeout with Some t -> string_of_float t | None -> "(none)")
		in Ocsigen_messages.warning msg;
		Lwt_timeout.start (Lwt_timeout.create pool.period (watcher pool));
		pool

