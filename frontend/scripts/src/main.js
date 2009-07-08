/********************************************************************************/
/* main.js									*/
/* Main programme.								*/
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

