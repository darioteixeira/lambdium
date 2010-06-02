/********************************************************************************/
/*	Main.js
	Copyright (c) 2010 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*/
/********************************************************************************/

var Main = {};


/********************************************************************************/
/* Module functions.								*/
/********************************************************************************/

/*
 * Top-level setup function.
 */
Main.setup = function ()
	{
	Obj.setup ();
	Previewer.setup ();
	};


/*
 * Top-level finalise function.
 */
Main.finalise = function ()
	{
	Previewer.finalise ();
	Obj.finalise ();
	};


/********************************************************************************/
/* Top-level statements: register window setup and cleanup handlers.		*/
/********************************************************************************/

Evt.register (window, Main.setup, "load");
Evt.register (window, Main.finalise, "unload");

