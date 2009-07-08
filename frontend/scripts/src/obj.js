/********************************************************************************/
/* obj.js									*/
/* Module for storing persistent objects.					*/
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

