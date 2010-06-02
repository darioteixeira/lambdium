/********************************************************************************/
/*	Obj.js
	Copyright (c) 2010 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*/
/********************************************************************************/

var Obj = {};


/********************************************************************************/
/* Module functions.								*/
/********************************************************************************/

/*
 * Top-level setup function.
 */
Obj.setup = function ()
	{
	Obj.objects = [];
	};


/*
 * Top-level finalise function.
 */
Obj.finalise = function ()
	{
	while (Obj.objects.length > 0)
		{
		var obj = Obj.objects.pop ();
		obj.finalise ();
		}
	};


/*
 * Adds a new object to the list.
 */
Obj.add = function (obj)
	{
	Obj.objects.push (obj);
	};

