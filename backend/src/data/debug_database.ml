(*	Test of the Postgresql API.
	Invoke with the following command:
	PGDATABASE="lambdium-light" ocamlfind ocamlc -package pgocaml.syntax -syntax camlp4o -i debug_database.ml
*)

let dbh = PGOCaml.connect ()

let get_timezones () =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_timezones ()"

let get_timezone tid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_timezone ($tid)"

let get_users () =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_users ()"

let get_user uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_user ($uid)"

let get_login nick password =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_login ($nick, $password)"

let get_stories uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_stories ($uid)"

let get_user_stories uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_stories ($uid)"

let get_story sid uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_story ($sid, $uid)"

let get_story_comments sid uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_story_comments ($sid, $uid)"

let get_user_comments uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_user_comments ($uid)"

let get_comment cid uid =
	PGSQL(dbh) "nullres=none" "SELECT * FROM get_comment ($cid, $uid)"

let add_user nick fullname password tid = 
	PGSQL(dbh) "SELECT add_user ($nick, $fullname, $password, $tid)"

let add_story uid title intro_src intro_ast intro_out body_src body_ast body_out =
	PGSQL(dbh) "SELECT add_story ($uid, $title, $intro_src, $intro_ast, $intro_out, $body_src, $body_ast, $body_out)"

let add_comment sid uid title body_src body_ast body_out =
	PGSQL(dbh) "SELECT add_comment ($sid, $uid, $title, $body_src, $body_ast, $body_out)"

let edit_user_credentials uid new_password old_password =
	PGSQL(dbh) "SELECT edit_user_credentials ($uid, $new_password, $old_password)"

let edit_user_settings uid fullname tid =
	PGSQL(dbh) "SELECT edit_user_settings ($uid, $fullname, $tid)"

let is_available_nick nick =
	PGSQL(dbh) "nullres=none" "SELECT * FROM is_available_nick ($nick)"

