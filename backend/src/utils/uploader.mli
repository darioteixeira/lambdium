type uploads_t

val make: Eliom_sessions.server_params -> uploads_t
val refresh: uploads_t -> unit
