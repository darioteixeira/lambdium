/********************************************************************************/
/* array.js									*/
/* Various functions to handle arrays.						*/
/********************************************************************************/

/*
 * Min function: returns the minimum element of the array.
 */

Array.prototype.min = function ()

	{
	return Math.min.apply (null, this);
	};

/*
 * Max function: returns the maximum element of the array.
 */

Array.prototype.max = function ()

	{
	return Math.max.apply (null, this);
	};

/*
 * Takes an array-like collection as parameter, returning its proper "arrayified" equivalent.
 */

Array.toArray = function (pseudoArray)

	{
	if (!pseudoArray)
		{
		return [];
		}
	else	{
		var result = [];
		for (var i=0; i < pseudoArray.length; i++)
			{
			result.push (pseudoArray [i]);
			}
		return result;
		}
	};

