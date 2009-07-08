/********************************************************************************/
/* bind.js									*/
/* Bind utilities.								*/
/********************************************************************************/

/*
 * Binds.
 */

Function.prototype.bind = function ()

	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	object = oldArgs.shift ();
	return function ()
		{
		var newArgs = Array.toArray (oldArgs);
		return method.apply (object, oldArgs.concat (newArgs));
		};
	};

/*
 * Binds as event listener.
 */

Function.prototype.bindAsEventListener = function (object)

	{
	var method = this;
	var oldArgs = Array.toArray (arguments);
	object = oldArgs.shift ();
	return function (evt)
		{
		var newArgs = Array.toArray (arguments);
		return method.apply (object, [(evt || window.event)].concat (oldArgs).concat(newArgs));
		};
	};

