/********************************************************************************/
/*	Bind.js
	Copyright (c) 2010 Dario Teixeira (dario.teixeira@yahoo.com)
	This software is distributed under the terms of the GNU GPL version 2.
	See LICENSE file for full license text.
*/
/********************************************************************************/

/*
 * Binds.
 */
Function.prototype.bind = function ()
	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	var context = oldArgs.shift ();

	return function ()
		{
		var newArgs = Array.toArray (arguments);
		return method.apply (context, oldArgs.concat (newArgs));
		};
	};


/*
 * Binds as event listener.
 */
Function.prototype.bindAsEventListener = function ()
	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	var context = oldArgs.shift ();

	return function (evt)
		{
		var newArgs = Array.toArray (arguments);
		return method.apply (context, [(evt || window.event)].concat (oldArgs).concat (newArgs));
		};
	};

