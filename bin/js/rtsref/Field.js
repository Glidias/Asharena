function Field(x, y, p_mode)
{
	if(p_mode)
	{
		this.px = x;
		this.py = y;
		this.x = Math.ceil(x);
		this.y = Math.ceil(y);
	}
	else
	{
		this.x = x;
		this.y = y;
		this.px = x - 0.5;
		this.py = y - 0.5;
	}
	
	this.f = 0;
	this.h = 0;
	this.g = 0;
	this.parent;
	this.closed = false;
	this.isOnOpenList = false;
	this.isField = true;
}

// get distance to other field, using field values
Field.prototype.distanceTo = function(otherField)
{
	return otherField ? Math.sqrt(Math.pow(this.x - otherField.x, 2) + Math.pow(this.y - otherField.y, 2)) : 999999;
}

// get distance to other field, using exact positions
Field.prototype.distanceTo2 = function(otherField)
{
	return otherField ? Math.sqrt(Math.pow(this.px - otherField.px, 2) + Math.pow(this.py - otherField.py, 2)) : 999999;
}

Field.prototype.raytrace = function(target, alsoCheckForUnits)
{
	var dist_x = target.px - this.px;
	var dist_y = target.py - this.py;
	
	var steps = Math.sqrt(dist_x * dist_x + dist_y * dist_y) / 0.25 - 1;
	var offset = new Field(0, 0, true).add2(this.getAngleTo(target) - Math.PI / 2, UNIT_RADIUS);
	var check = this.getCopy();
	
	var step_x = dist_x / steps;
	var step_y = dist_y / steps;
	
	for(var i = 0; i < steps; i++)
	{
		check.px += step_x;
		check.py += step_y;
		
		if(game.fieldIsBlocked(Math.ceil(check.px + offset.px), Math.ceil(check.py + offset.py)) || game.fieldIsBlocked(Math.ceil(check.px - offset.px), Math.ceil(check.py - offset.py)) || (alsoCheckForUnits && check.collidesWithBlockingUnits()))
			return false;
	}
	
	return true;
}

// checks if position is not blocked (only checks for buildings and tiles, not units)
Field.prototype.positionIsValid = function()
{
	for(i = 0; i < circleOffsets.length; i++)
		if(game.fieldIsBlocked(Math.ceil(this.px + circleOffsets[i][0]), Math.ceil(this.py + circleOffsets[i][1])))
			return false;
	return true;
}

Field.prototype.getNextFreePosition = function()
{
	var angle = 0;
	var len = 0;
	while(!this.add2(angle, len).positionIsValid())
	{
		angle += Math.PI / 8;
		len += 0.01;
	}
	return this.add2(angle, len);
}

Field.prototype.isSameGrid = function(otherField)
{
	return this.x == otherField.x && this.y == otherField.y;
}

// checks, if the unit collides with a blocking unit (enemy unit or allied unit, that has hold position order for exapmle)
Field.prototype.collidesWithBlockingUnits = function()
{
	for(var i = 0; i < game.units.length; i++)
		if(game.units[i].blocking && this.distanceTo2(game.units[i].pos) < UNIT_WIDTH)
			return true;
	return false;
}

// get vector from here to other Field
Field.prototype.vectorTo = function(otherField)
{
	return new Field(otherField.px - this.px, otherField.py - this.py, true);
}

Field.prototype.normalize = function(factor)
{
	var len = Math.sqrt(this.px * this.px + this.py * this.py);
	if(len == 0)
		len = 0.001;
	
	this.px *= factor / len;
	this.py *= factor / len;
	return this;
}

Field.prototype.getLen = function()
{
	return Math.sqrt(this.px * this.px + this.py * this.py);
}

// adds a vector to this one from x and y values
Field.prototype.add = function(otherField)
{
	return new Field(this.px + otherField.px, this.py + otherField.py, true);
}

Field.prototype.addNormalizedVector = function(otherField, len)
{
	var x = otherField.px - this.px;
	var y = otherField.py - this.py;
	
	var len2 = Math.sqrt(x * x + y * y);
	if(len2 == 0)
		len2 = 0.001;
	
	x *= len / len2;
	y *= len / len2;
	
	return new Field(this.px + x, this.py + y, true);
}

// adds a vector to this one from a given angle and length
Field.prototype.add2 = function(angle, len)
{
	return this.add(new Field(Math.cos(angle), Math.sin(angle), true).normalize(len));
}

// get angle from this point to another point (works even in div/0 case, tested)
Field.prototype.getAngleTo = function(otherField)
{
	var returnValue = Math.atan((otherField.py - this.py) / (otherField.px - this.px));
	returnValue -= otherField.px - this.px < 0 ? Math.PI : 0;
	return returnValue;
}

Field.prototype.getCopy = function()
{
	return new Field(this.px, this.py, true);
}

Field.prototype.equals = function(otherField)
{
	return this.px == otherField.px && this.py == otherField.py;
}

Field.prototype.toString = function()
{
	return this.px + ":" + this.py;
}