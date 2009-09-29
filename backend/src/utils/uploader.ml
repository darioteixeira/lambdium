open Common

type uploads_t = ResourceGC.token_t


let pool =
	let timeout = match Eliom_sessions.get_global_service_session_timeout () with
		| Some t -> t
		| None	 -> 3600.0
	in lazy (ResourceGC.make_pool "Uploader" 20 timeout)


let make sp =
	let timeout = Eliom_sessions.get_service_session_timeout ~sp () in
	let cleaner () = Ocsigen_messages.warning "Cleaner called!"
	in ResourceGC.get_token ?timeout !!pool cleaner


let refresh uploads =
	ResourceGC.refresh_token !!pool uploads

