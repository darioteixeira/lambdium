(********************************************************************************)
(*	Id.ml
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(**	The type that all ID modules should satisfy.  Basically, besides the
	type [t] they should have functions for converting [t] to/from strings
	and to produce a valid [Eliom_parameters.user_type] for use as parameter
	to services.
*)
module type ID =
sig
	type t

	val to_string : t -> string
	val of_string : string -> t
	val param : string -> (t, [ `WithoutSuffix ], [ `One of t ] Eliom_parameters.param_name) Eliom_parameters.params_type
end


(**	The type of modules that used int32 as the ID type.  The reason why
	int32 is used instead of regular int, is because only int32 maps
	directly into the int4 type used in PostgreSQL.  And remember that
	PG'OCaml makes sure this mapping is correct.
*)
module type ID32 = ID with type t = int32


(**	The type of modules that used int64 as the ID type.  The reason why
	int64 is used instead of regular int, is because only int64 maps
	directly into the int8 type used in PostgreSQL.  And remember that
	PG'OCaml makes sure this mapping is correct.
*)
module type ID64 = ID with type t = int64


(**	A concrete implementation of a module obeying the ID32 type.  It simply
	borrows the Int32.to_string and Int32.of_string functions to provide
	the to/from string conversion.
*)
module Id32 : ID32 =
struct
	type t = int32

	let to_string = Int32.to_string
	let of_string = Int32.of_string
	let param = Eliom_parameters.user_type of_string to_string
end


(**	A concrete implementation of a module obeying the ID64 type.  It simply
	borrows the Int64.to_string and Int64.of_string functions to provide
	the to/from string conversion.
*)
module Id64 : ID64 =
struct
	type t = int64

	let to_string = Int64.to_string
	let of_string = Int64.of_string
	let param = Eliom_parameters.user_type of_string to_string
end

