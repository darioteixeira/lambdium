(********************************************************************************)
(*	Timezone_io.mli
	Copyright (c) 2009 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*)
(********************************************************************************)

(********************************************************************************)
(**	{1 Output-related functions}						*)
(********************************************************************************)

val output_full:
	Timezone.full_t ->
	[> `Dl ] XHTML.M.elt

val describe:
	Timezone.full_t ->
	Xhtmltypes.pcdata XHTML.M.elt

