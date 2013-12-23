Unit.prototype = new MapObject();
function Unit(data)
{
	// basic attributes
	this.pos = new Field(data.x, data.y, true);
	this.type = data.type;
	this.owner = data.owner;
	this.owner.supply++;
	this.hp = data.type.hp;
	this.id = game.global_id++;
	this.killedFromPos = null; // position from where the kill came, so dying unit can be moved towards the opposing position
	
	// everything regarding the current order
	this.order = COMMAND.IDLE;
	this.path = [];
	this.target = null;
	this.buildingToMake = null;
	this.carriesGold = false;
	this.goldMine = null; // the goldmine currently mining from
	this.pseudoBuildings = []; // if building orders queued, store pseudo objects oft buildings here, to draw them (with low alpha)
	this.lastAttackingTick = 0;
	this.lastTickCheckedForNextEnemyUnit = 0;
	this.tickOfLastWeaponFired = 0;
	this.targetLockingUnit = null;
	
	// order queue
	this.queueOrder = [];
	this.queueTarget = [];
	
	// pushing / blocking
	this.blocking = false;
	this.lastTickSetPushPrio = 0;
	this.lastFramesPosition = this.pos.getCopy();
	this.pushPrio = 0;
	this.timesPushedThisFrame = 0;
	this.lastTickPathRecalculated = 0;
	this.drawPos = null;
	this.direction = Math.floor(Math.random() * 4);
	
	game.units.push(this);
	this.owner.updateVisionUnit(this);
	this.hitOffsetPos = null;
	this.hitOffsetTill = 0;
	this.lastTickCircleEffect = 0;
	this.lastRepairSound = 0;
}

// this is called each frame after all the moving has been done
Unit.prototype.checkPushPrio = function()
{
	// check for collision with other units
	for(var i = 0; i < game.units.length; i++)
	{
		var dist = this.pos.distanceTo2(game.units[i].pos) - UNIT_WIDTH;
		if(game.units[i] != this && dist < 0 && game.units[i].order != COMMAND.MINE && this.order != COMMAND.MINE)
		{
			// if pos exactly the same, move one unit a little bit, otherwise game would crash
			this.pos = this.pos.equals(game.units[i].pos) ? this.pos.add(new Field(0.1, 0.1, true)) : this.pos;
			
			if(!this.blocking) // if this not blocking, then move it away from the colliding unit
				this.pos = this.pos.addNormalizedVector(game.units[i].pos, -Math.min(this.type.pixelPerTick, -dist));
			
			if(!game.units[i].blocking) // if other unit not blocking, then move it away from this unit
				game.units[i].pos = game.units[i].pos.addNormalizedVector(this.pos, -Math.min(game.units[i].type.pixelPerTick, -dist));
		}
	}
}

// called every frame after all the moving and pushing stuff is done
Unit.prototype.afterMove = function()
{
	var distanceMovedThisFrame = this.pos.distanceTo2(this.lastFramesPosition);
	
	// limit the moved distance to 1,5 times the distance the units can move
	if(distanceMovedThisFrame > this.type.pixelPerTick * 1.5)
	{
		this.pos = this.lastFramesPosition.addNormalizedVector(this.pos, this.type.pixelPerTick * 1.5);
		distanceMovedThisFrame = this.type.pixelPerTick * 1.5;
	}
	
	// if pos is not valid, look for next valid pos
	this.pos = this.pos.getNextFreePosition();
	
	// if this unit has moved to another grid, update vision
	if(!this.pos.isSameGrid(this.lastFramesPosition))
		this.owner.updateVisionUnit(this);
	
	// check if push prio needs to be highered
	if(distanceMovedThisFrame < this.type.pixelPerTick * 0.25 && this.path.length > 0)
	{
		this.pushPrio++;
		this.lastTickSetPushPrio = ticksCounter;
	}
	if(this.lastTickSetPushPrio + 10 < ticksCounter)
		this.pushPrio = 0;
	
	
	// is path to target pretty much blocked by units and not much distance left, remove target
	if(this.timesPushedThisFrame > 0 && distanceMovedThisFrame < this.type.pixelPerTick * 0.3 && this.path.length > 0 && this.pos.distanceTo2(this.path[this.path.length - 1]) < 3 && (this.order == COMMAND.MOVE || this.order == COMMAND.AMOVE))
	{
		var countBlocks = 0;
		var countSteps = 0.01;
		var dist = this.pos.distanceTo2(this.path[this.path.length - 1]) + UNIT_RADIUS * 0.5;
		for(var d = UNIT_RADIUS * 0.75; d < dist; d += UNIT_RADIUS / 4)
		{
			countSteps++;
			var pos = this.pos.addNormalizedVector(this.path[this.path.length - 1], d);
			for(var i = 0; i < game.units.length; i++)
				if(game.units[i].pos.distanceTo(pos) < UNIT_WIDTH)
				{
					countBlocks++;
					break;
				}
		}
		
		if(countBlocks / countSteps > 0.7)
			this.path.pop();
	}
}

Unit.prototype.push2 = function(pushingUnit, pos)
{
	// find best pushPos
	var baseAngle = this.pos.getAngleTo(pos);
	var dist = this.pos.distanceTo2(pos);
	var checkPos = null;
	var blockState = BLOCK_STATE.UNBLOCKED;
	for(var i = 0; i < pushDistances.length; i++)
		for(var k = 0; k < pushPosAngles.length; k++)
		{
			checkPos = this.pos.add2(baseAngle + pushPosAngles[k], dist * pushDistances[i]);
			if(checkPos.positionIsValid())
			{
				if( !checkPos.collidesWithBlockingUnits())
				{
					this.pos = checkPos;
					i = pushDistances.length;
					k = pushPosAngles.length;
				}
				else
					blockState = BLOCK_STATE.BLOCKED_BY_UNITS;
			}
			else
				blockState = blockState == BLOCK_STATE.UNBLOCKED ? BLOCK_STATE.BLOCKED_BY_STATIC_OBJECTS : blockState;
		}
	
	// check if collide with other units and push, if yes
	for(var i = 0; i < game.units.length; i++)
		if(game.units[i] != this && this.owner == game.units[i].owner && this.distanceTo(game.units[i]) < 0 && game.units[i].order != COMMAND.MINE && this.order != COMMAND.MINE)
			if(!game.units[i].blocking && (this.pushPrio >= game.units[i].pushPrio || game.units[i].order == COMMAND.IDLE) && this.timesPushedThisFrame < 2)
			{
				this.timesPushedThisFrame++;
				game.units[i].push2(this, this.pos.addNormalizedVector(game.units[i].pos, UNIT_WIDTH));
			}
	
	
	// if not just done and pushed by another unit, recalculate path
	if(pushingUnit && this.lastTickPathRecalculated + 20 < ticksCounter && this.path.length > 1)
	{
		this.lastTickPathRecalculated = ticksCounter;
		
		if(this.pos.raytrace(this.path[this.path.length - 2]))
		{
			if(this.path.length > 2)
			{
				var newPath = this.getPath(this.path[this.path.length - 2].px, this.path[this.path.length - 2].py, this.targetUnit);
				this.path.splice(this.path.length - 2, 2);
				this.path = this.path.concat(newPath);
			}
			else
				this.path = this.getPath(this.path[0].px, this.path[0].py, this.targetUnit);
		}
	}
	
	return blockState;
}

// remove add to game array
Unit.prototype.switchBlocking = function(on)
{
	if(on)
		game.units.push(this);
	else
		game.units.erease(this);
}

Unit.prototype.distanceTo = function(otherUnit)
{
	if(!otherUnit)
		return 999999;
	return otherUnit.type.isBuilding ? otherUnit.distanceTo(this) : this.pos.distanceTo2(otherUnit.pos) - UNIT_WIDTH;
}

Unit.prototype.resetMakeBuilding = function()
{
	// check if make buildign orders were queued, if yes, give back the money, because theyre cancelled
	if(this.order == COMMAND.MAKECC || this.order == COMMAND.MAKERAX || this.order == COMMAND.MAKETOWER)
		this.owner.modifyGold(this.buildingToMake.cost);
	
	for(var i = 0; i < this.queueOrder.length; i++)
		if(this.queueOrder[i] == COMMAND.MAKECC || this.queueOrder[i] == COMMAND.MAKERAX || this.queueOrder[i] == COMMAND.MAKETOWER)
			this.owner.modifyGold(getUnitTypeFromCommand(this.queueOrder[i]).cost);
	
	// delete elements from game's pseudoBuildings array and delete this pseudoBuildings array
	for(var i = 0; i < this.pseudoBuildings.length; i++)
		game.pseudoBuildings.erease(this.pseudoBuildings[i]);
	
	this.pseudoBuildings = [];
}

Unit.prototype.issueOrder = function(order, target, intern, shift)
{
	// if intern command, dont reset queues and stuff
	if(!intern)
	{
		if(!shift)
			this.resetMakeBuilding();
		
		if(order == COMMAND.MAKECC || order == COMMAND.MAKERAX || order == COMMAND.MAKETOWER)
		{
			var buildingType = getUnitTypeFromCommand(order);
			
			if(this.owner.gold >= buildingType.cost)
			{
				this.owner.modifyGold(-buildingType.cost);
				if(this.owner.controller == CONTROLLER.HUMAN)
				{
					this.pseudoBuildings.push(new Building({"x": target.x, "y": target.y, "type": buildingType, "owner": this.owner, "buildFirst": false, "isDummy": true}));
					game.pseudoBuildings.push(this.pseudoBuildings[this.pseudoBuildings.length - 1]);
				}
			}
			else
				return;
		}
		
		if(shift)
		{
			if(this.queueOrder.length < 9)
			{
				this.queueOrder.push(order);
				this.queueTarget.push(target);
			}
			return;
		}
		
		// reset shift queues
		this.queueOrder = [];
		this.queueTarget = [];
	}
	
	this.order = order;
	this.path = [];
	this.targetUnit = null;
	
	// play sound
	if(DRAWING && game.lastYesSound + 100 < ticksCounter && this.owner == PLAYING_PLAYER)
	{
		soundManager.playSound(SOUND.YES, this.pos, 0.6);
		game.lastYesSound = ticksCounter;
	}
	
	if(order == COMMAND.ATTACK)
		this.targetUnit = target;
	
	if(order == COMMAND.AMOVE)
	{
		this.target = target.getNextFreePosition();
		this.lastTickCheckedForNextEnemyUnit = 0;
	}
	
	if(order == COMMAND.MOVE)
		this.path = this.getPath(target.px, target.py);
	
	if(order == COMMAND.IDLE || order == COMMAND.HOLDPOSITION)
		this.target = null;
	
	if(order == COMMAND.MAKECC || order == COMMAND.MAKERAX || order == COMMAND.MAKETOWER)
	{
		this.buildingToMake = getUnitTypeFromCommand(order);
		
		var moveTarget = new Field(target.px + this.buildingToMake.size / 2, target.py + this.buildingToMake.size / 2, true);
		this.path = this.getPath(moveTarget.px, moveTarget.py);
		
		if(this.path && this.path[0].distanceTo2(moveTarget) < 1)
			this.target = target;
		else
			this.issueOrder(COMMAND.IDLE);
	}
	
	if(order == COMMAND.MINE)
		this.goldMine = target;
	
	if(order == COMMAND.MOVETO)
	{
		this.targetUnit = target;
		this.path = this.getPath(target.pos.px, target.pos.py, target);
	}
}

// return true if unit is inside a drawn box
Unit.prototype.isInBox = function(x1, y1, x2, y2)
{
	return this.pos.px + 0.5 >= x1 && this.pos.py + 0.5 >= y1 && this.pos.px - 0.5 <= x2 && this.pos.py - 0.5 <= y2;
}

// calculate path to target position, optional ignoreUnit: ignore this unit while finding path
Unit.prototype.getPath = function(x, y, ignoreUnit)
{
	// deactivate blocking for the ignore unit, in cased there is one
	if(ignoreUnit && ignoreUnit.type.isBuilding)
		ignoreUnit.switchBlocking(false);
	
	var openList = [];
	var closedList = [];
	var exactTarget = new Field(x, y, true).getNextFreePosition();
	var exactStart = new Field(this.pos.px, this.pos.py, true);
	var targetNode = game.fields[exactTarget.x][exactTarget.y];
	var startNode = game.fields[exactStart.x][exactStart.y];
	
	if(targetNode == startNode) // if target == start, erturn exact target if valid, else empty array => no moving
		return exactTarget.positionIsValid() ? [exactTarget] : [];
	
	// insert Start Node as closed and nB's as open
	openList.push(startNode);
	startNode.g = 0;
	startNode.h = startNode.distanceTo(targetNode);
	startNode.f = startNode.h;
	startNode.isOnOpenList = true;
	
	while(true)
	{
		// if open list empty => target not reachable
		if(openList.length == 0)
		{
			// find closest Field from closedList, put it back on openList, so it will be found as next Field to check
			var closestIndex = 0;
			for(var i = 0; i < closedList.length; i++)
				if(closedList[i].distanceTo(targetNode) < closedList[closestIndex].distanceTo(targetNode))
					closestIndex = i;
			openList.push(closedList[closestIndex]);
			targetNode = closedList[closestIndex];
			exactTarget = targetNode;
		}
		
		// get 'best' field from OpenList
		var currentNodeIndex = 0;
		for(var i = 0; i < openList.length; i++)
			if(openList[i].f < openList[currentNodeIndex].f)
				currentNodeIndex = i;
		var currentNode = openList[currentNodeIndex];
		
		nbs = game.getNBNodes(currentNode.x, currentNode.y, ignoreUnit);
		for(var i = 0; i < nbs.length; i++)
		{
			var nb = nbs[i];
			
			// if node already closed, skip
			if(nb.closed)
				continue;
			
			if(!nb.isOnOpenList) // if the field is not on the list yet, add it
			{
				openList.push(nb);
				nb.isOnOpenList = true;
				nb.parent = currentNode;
				nb.g = currentNode.g + nb.distanceTo(currentNode);
				nb.h = nb.distanceTo(targetNode);
				nb.f = nb.g + nb.h;
			}
			else
			{
				var new_g = currentNode.g + currentNode.distanceTo(nb);
				if(new_g < nb.g) // new way to tempField is better than the existing one
				{
					nb.g = new_g;
					nb.f = nb.g + nb.h;
					nb.parent = currentNode; // set this Field as new parent, because it offers the best way
				}
			}
		}
		
		// move field from open to closed list
		openList.splice(currentNodeIndex, 1);
		closedList.push(currentNode);
		currentNode.isOnOpenList = false;
		currentNode.closed = true;
		
		if(currentNode == targetNode) // we have found the best way
		{
			var path = [targetNode];
			while(path[path.length - 1].parent != startNode)
				path.push(path[path.length - 1].parent);
			// add exact target as final target, if passable
			if(exactTarget.positionIsValid())
				path.splice(0, 0, exactTarget);
			
			// path smoothing
			var index = path.length - 2; // highest Field, that has to be checked
			while(index >= 0)
			{
				if(exactStart.raytrace(path[index]))
					path.splice(index + 1, 1);
				else
					exactStart = path[index + 1];
				index--;
			}
			
			// clear all the fields 'isOnOpenList' & 'closed' values
			var usedFields = openList.concat(closedList);
			for(var i = 0; i < usedFields.length; i++)
			{
				usedFields[i].isOnOpenList = false;
				usedFields[i].closed = false;
			}
			
			// reactivate blocking for the ignore unit, in cased there is one
			if(ignoreUnit && ignoreUnit.type.isBuilding)
				ignoreUnit.switchBlocking(true);
			
			// return path
			return path;
		}
	}
}

Unit.prototype.update = function()
{
	this.blocking = false;
	this.timesPushedThisFrame = 0;
	
	if(this.order == COMMAND.MOVETO && (!this.targetUnit || this.distanceTo(this.targetUnit) < 0.2))
	{
		this.issueOrder(COMMAND.IDLE, null, true);
	}
	
	// unit, this unit is moving to, has moved away from actual target point, so recalculate path
	if(this.order == COMMAND.MOVETO && this.targetUnit && this.path[0].distanceTo2(this.targetUnit.pos) >= 0.2)
		this.path = this.getPath(this.targetUnit.pos.px, this.targetUnit.pos.py);
	

	
	// attack
	if(this.order == COMMAND.ATTACK)
	{
		if(!this.targetUnit || !this.targetUnit.isActive) // target unit is dead or non existant
		{
			this.issueOrder(COMMAND.IDLE, null, true);
			return;
		}
		
		if(this.distanceTo(this.targetUnit) <= this.type.range || (this.targetUnit == this.targetLockingUnit && this.lastAttackingTick == ticksCounter - 1)) // if this unit can hit target unit (rangewise)
		{
			this.hitCycle = this.lastAttackingTick != ticksCounter - 1 ? 0 : this.hitCycle + 1;
			this.lastAttackingTick = ticksCounter;
			
			// if new target lock has to be applied
			if(this.distanceTo(this.targetUnit) <= this.type.range && ticksCounter - this.tickOfLastWeaponFired >= this.type.getWeaponCooldownInTicks() - this.type.getWeaponDelayInTicks())
				this.targetLockingUnit = this.targetUnit;
			
			if(this.hitCycle >= this.type.getWeaponDelayInTicks() && ticksCounter >= this.tickOfLastWeaponFired + this.type.getWeaponCooldownInTicks()) // if the unit can hit this frame
			{
				this.tickOfLastWeaponFired = ticksCounter;
				this.performHit(this.targetUnit);
				this.targetLockingUnit = null;
			}
			this.blocking = true; // unit is attacking, so its not pushable
			return;
		}
		
		if(this.path.length == 0 || this.path[0].distanceTo2(this.targetUnit.pos) > 1) // path needs to be recalculated (either it has not been calculated yet or target unit has moved)
		{
			var newPath = this.getPath(this.targetUnit.pos.px, this.targetUnit.pos.py, this.targetUnit);
			if(newPath[0].distanceTo2(this.targetUnit.pos) < 1)
				this.path = newPath;
			else
				this.issueOrder(COMMAND.IDLE, null, true);
		}
	}
	
	if(this.order == COMMAND.AMOVE || this.order == COMMAND.IDLE || this.order == COMMAND.HOLDPOSITION) // a move / idle / hold position
	{
		if(this.order == COMMAND.HOLDPOSITION)
			this.blocking = true;
		
		// idle workers dont attack in their own
		if(this.type == WORKER && this.order == COMMAND.IDLE)
			this.targetUnit = null;
		
		// look for best target
		else if(this.lastTickCheckedForNextEnemyUnit + 5 < ticksCounter)
		{
			this.targetUnit = game.getHighestPrioEnemyUnitInRange(this, this.type.vision);
			this.lastTickCheckedForNextEnemyUnit = ticksCounter;
		}
		
		if(this.targetUnit && ((this.targetUnit == this.targetLockingUnit && this.lastAttackingTick == ticksCounter - 1) || this.distanceTo(this.targetUnit) <= this.type.range)) // if this unit can hit target unit (rangewise)
		{
			this.hitCycle = this.lastAttackingTick != ticksCounter - 1 ? 0 : this.hitCycle + 1;
			this.lastAttackingTick = ticksCounter;
			
			// if new target lock has to be applied
			if(this.distanceTo(this.targetUnit) <= this.type.range && ticksCounter - this.tickOfLastWeaponFired >= this.type.getWeaponCooldownInTicks() - this.type.getWeaponDelayInTicks())
				this.targetLockingUnit = this.targetUnit;
			
			if(this.hitCycle >= this.type.getWeaponDelayInTicks() && ticksCounter >= this.tickOfLastWeaponFired + this.type.getWeaponCooldownInTicks()) // if the unit can hit this frame
			{
				this.tickOfLastWeaponFired = ticksCounter;
				this.performHit(this.targetUnit);
				this.targetLockingUnit = null;
			}
			this.blocking = true; // unit is attacking, so its not pushable
			return;
		}
		
		// if enemy in vision but no or wrong path to it, calculate new path (only if no hold position)
		if(this.targetUnit && this.order != COMMAND.HOLDPOSITION && (this.path.length == 0 || this.path[0].distanceTo2(this.targetUnit.pos) > 1))
		{
			if(this.order == COMMAND.IDLE) // is enemy in range and order was idle, issue amove cmd to current position, so unit comes back after attacking
			{
				this.order = COMMAND.AMOVE;
				this.target = this.pos.getCopy();
			}
			this.path = this.getPath(this.targetUnit.pos.px, this.targetUnit.pos.py, this.targetUnit.type.isBuilding ? this.targetUnit : null);
		}
		
		// if no enemy unit in vision range and no path to target is set
		if(this.order == COMMAND.AMOVE && this.target && (!this.targetUnit || this.distanceTo(this.targetUnit) > this.type.vision) && (this.path.length == 0 || !this.path[0].equals(this.target)))
		{
			this.path = this.getPath(this.target.px, this.target.py);
			this.target = this.path[0].getCopy(); // set new target, because if target not reachable, replace it with nearest reachable point
		}
	}
	
	if(this.path.length > 0) // move
	{
		
		var vec_to_next_node = this.pos.vectorTo(this.path[this.path.length - 1]);
		var dist = vec_to_next_node.getLen();
		var oldPos = this.pos.getCopy();
		if(dist <= this.type.pixelPerTick) // if unit can reach next node this tick, remove this node
			this.path.pop();
		
		if(dist > 0)
		{
			var blockState = this.push2(null, this.pos.add(vec_to_next_node.normalize(Math.min(this.type.pixelPerTick, dist))));
			
			// if units are blocking, search a path around em
			if(blockState == BLOCK_STATE.BLOCKED_BY_UNITS && this.path.length > 0 && this.lastTickPathRecalculated + 20 < ticksCounter)
			{
				this.lastTickPathRecalculated = ticksCounter;
				
				if(this.targetUnit)
					this.targetUnit.switchBlocking(false);
				
				var path = [[this.pos], [this.pos]];
				while(this.path.length > 1 && this.pos.distanceTo2(this.path[this.path.length - 1]) < 5)
					this.path.pop();
				
				for(var i = 0; i <= 1; i++)
					while(path[i].length < 24 && !path[i][path[i].length - 1].raytrace(this.path[this.path.length - 1], true))
					{
						var angle = path[i][path[i].length - 1].getAngleTo(this.path[this.path.length - 1]);
						var nextNode = path[i][path[i].length - 1].add2(angle, UNIT_RADIUS);
						
						var counter = 0;
						while(nextNode.positionIsValid() && !nextNode.collidesWithBlockingUnits() && counter < 16)
						{
							counter++;
							angle -= Math.PI / 8 * (i == 0 ? 1 : -1);
							nextNode = path[i][path[i].length - 1].add2(angle, UNIT_RADIUS);
						}
						while(!nextNode.positionIsValid() || nextNode.collidesWithBlockingUnits() && counter < 16)
						{
							counter++;
							angle += Math.PI / 8 * (i == 0 ? 1 : -1);
							nextNode = path[i][path[i].length - 1].add2(angle, UNIT_RADIUS);
						}
						path[i].push(nextNode);
					}
				
				if(this.targetUnit)
					this.targetUnit.switchBlocking(true);
				
				var bestPath = path[0].length < path[1].length ? path[0] : path[1];
				for(i = bestPath.length - 1; i > 0; i--)
					this.path.push(bestPath[i]);
			}
			
			// if not just done and blocked by static objects, recalculate path
			if(blockState == BLOCK_STATE.BLOCKED_BY_STATIC_OBJECTS && this.lastTickPathRecalculated + 10 < ticksCounter && this.path.length > 0)
			{
				this.lastTickPathRecalculated = ticksCounter;
				if(this.path.length > 2)
				{
					var newPath = this.getPath(this.path[this.path.length - 2].px, this.path[this.path.length - 2].py, this.targetUnit);
					this.path.splice(this.path.length - 2, 2);
					this.path = this.path.concat(newPath);
				}
				else
					this.path = this.getPath(this.path[0].px, this.path[0].py, this.targetUnit);
			}
		}
	}
	
	if(this.path.length == 0 && this.order != COMMAND.HOLDPOSITION) // move, aber keine targets mehr -> umstellen auf idle
		this.order = COMMAND.IDLE;
	
	if(this.order == COMMAND.IDLE && this.queueOrder.length > 0) // no orders, but orders in queue, issue first order from queue
	{
		this.issueOrder(this.queueOrder[0], this.queueTarget[0], true);
		this.queueOrder.splice(0, 1);
		this.queueTarget.splice(0, 1);
	}
}

Unit.prototype.updateDrawPosition = function()
{
	this.drawPos = this.lastFramesPosition.addNormalizedVector(this.pos, percentageOfCurrentTickPassed * this.pos.distanceTo2(this.lastFramesPosition));
	this.drawPos = (this.hitOffsetTill > timestamp && this.hitOffsetPos) ? this.drawPos.addNormalizedVector(this.hitOffsetPos, -0.02) : this.drawPos;
}

Unit.prototype.draw = function()
{
	// if ourside if visible bounds or not visible (fogwise), return, because we dont need to draw anything
	if(!this.isInBox(game.cameraX / FIELD_SIZE, game.cameraY / FIELD_SIZE, (game.cameraX + WIDTH) / FIELD_SIZE, (game.cameraY + HEIGHT) / FIELD_SIZE) || !PLAYING_PLAYER.canSeeUnit(this))
		return
	
	// if unit is dying, play death animation
	if(!this.isAlive)
	{
		var isDeadForHowLong = ticksCounter - this.tickOfDeath;
		
		// move unit slightly
		this.drawPos = this.drawPos.addNormalizedVector(this.killedFromPos, -timeDiff * Math.max((15 - isDeadForHowLong) / 15, 0));
		
		var heightGraph = -Math.pow(isDeadForHowLong / 4 - 1, 2) + 1;
		
		var additionalHeight = Math.max(heightGraph, 0) * 12;
		
		// create smoke effect when hit the ground
		if(heightGraph < 0 && heightGraph > -10 && Math.random() < 0.1)
			game.effects.push(new Dust(this.pos.px, this.pos.py));
		
		// get drawing position
		var x = this.drawPos.px * FIELD_SIZE - 18 * SCALE_FACTOR / 2 - game.cameraX;
		var y = this.drawPos.py * FIELD_SIZE - 16 * SCALE_FACTOR / 2 - game.cameraY - 8 - additionalHeight;
		
		var img = this.type.img[this.owner.number][ANIMATION.DIE];
		var frame = Math.floor(Math.min(isDeadForHowLong * 0.6, img.width / 18 - 1));
		
		c.globalAlpha = isDeadForHowLong > 150 ? Math.max(200 - isDeadForHowLong, 0) / 50 : 1;
		
		// unit img
		c.drawImage(img, frame * 18, this.direction * 16, 18, 16, x, y, 18 * SCALE_FACTOR, 16 * SCALE_FACTOR);
		
		c.globalAlpha = 1;
		
		if(isDeadForHowLong > 200)
			game.dyingUnits.erease(this);
		
		return;
	}
	
	var angle = 999;
	var img = this.type.img[this.owner.number][ANIMATION.WALK];
	var frame = 0;
	
	// get drawing position
	var x = this.drawPos.px * FIELD_SIZE - 18 * SCALE_FACTOR / 2 - game.cameraX;
	var y = this.drawPos.py * FIELD_SIZE - 16 * SCALE_FACTOR / 2 - game.cameraY - 8;
	
	// if walk
	if(!this.lastFramesPosition.equals(this.pos))
	{
		// if carries gold
		if(this.carriesGold)
			img = this.type.img[this.owner.number][ANIMATION.WALK_WITH_GOLD];
		
		angle = this.path.length > 0 ? this.pos.getAngleTo(this.path[this.path.length - 1]) : this.lastFramesPosition.getAngleTo(this.pos);
		frame = Math.floor((ticksCounter / 1.5) % (img.width / 18));
		
		// dust effect
		if(Math.random() < 0.017)
		{
			var effectPos = this.pos.addNormalizedVector(this.lastFramesPosition, 0.1);
			game.effects.push(new Dust(effectPos.px, effectPos.py + 0.2));
		}
	}
	
	// if attack
	if((this.lastAttackingTick + 1 >= ticksCounter || this.order == COMMAND.REPAIR) && this.targetUnit)
	{
		img = this.type.img[this.owner.number][ANIMATION.ATTACK];
		angle = this.pos.getAngleTo(this.targetUnit.pos);
		
		if(ticksCounter - this.tickOfLastWeaponFired < this.type.getWeaponCooldownInTicks()) // if weapon has been fired recently and is cooldowning now
			frame = Math.floor(((ticksCounter - this.tickOfLastWeaponFired + this.type.getWeaponDelayInTicks()) % this.type.getWeaponCooldownInTicks()) / this.type.getWeaponCooldownInTicks() * (img.width / 18));
		else
			frame = Math.floor((this.hitCycle % this.type.getWeaponCooldownInTicks()) / this.type.getWeaponCooldownInTicks() * (img.width / 18));
	}
	
	if(angle != 999) // if a new angle ha been calculated, calculate the new direction from it
	{
		angle += angle < -Math.PI ? Math.PI * 2 : 0;
		angle -= angle > Math.PI ? Math.PI * 2 : 0;
		
		if(angle > Math.PI / 4 && angle < Math.PI * 3 / 4)
			this.direction = DIRECTION.FRONT;
		else if(angle < -Math.PI / 4 && angle > -Math.PI * 3 / 4)
			this.direction = DIRECTION.BACK;
		else if(angle >= Math.PI * 3 / 4 || angle <= -Math.PI * 3 / 4)
			this.direction = DIRECTION.LEFT;
		else
			this.direction = DIRECTION.RIGHT;
	}
	
	// shadow
	c.drawImage(imgShadow, this.drawPos.px * FIELD_SIZE - FIELD_SIZE / 2 - game.cameraX, this.drawPos.py * FIELD_SIZE - FIELD_SIZE / 2 - game.cameraY, FIELD_SIZE, FIELD_SIZE);
	
	// unit
	c.drawImage(img, frame * 18, this.direction * 16, 18, 16, x, y, 18 * SCALE_FACTOR, 16 * SCALE_FACTOR);
	
	// debugs
	if(show_unit_details)
	{
		// show orders
		var arr = ["ATTACK", "IDLE", "HOLDPOSITION", "MAKEWORKER", "MAKESOLDIER", "MAKERIFLEMAN.", "MOVE", "MAKECC", "MAKERAX", "MAKETOWER", "MINE", "NONE", "REPAIR", "AMOVE"];
		c.fillStyle = "rgba(0, 0, 0, 1)";
		c.fillText(arr[this.order], this.pos.px * FIELD_SIZE - game.cameraX - FIELD_SIZE / 2, (this.pos.py - this.type.healthbarOffset) * FIELD_SIZE - game.cameraY - 12);
	
		// show detailed path to next target
		if(this.path.length > 0)
		{
			c.strokeStyle = "yellow";
			c.beginPath();
			c.moveTo(this.pos.px * FIELD_SIZE - game.cameraX, this.pos.py * FIELD_SIZE - game.cameraY);
			c.lineTo(this.path[this.path.length - 1].px * FIELD_SIZE - game.cameraX, this.path[this.path.length - 1].py * FIELD_SIZE - game.cameraY);
			for(var i = this.path.length - 2; i >= 0; i--)
				c.lineTo(this.path[i].px * FIELD_SIZE - game.cameraX, this.path[i].py * FIELD_SIZE - game.cameraY);
			c.stroke();
	
			// show all queued paths
			c.strokeStyle = "white";
			c.beginPath();
			c.moveTo(this.pos.px * FIELD_SIZE - game.cameraX, this.pos.py * FIELD_SIZE - game.cameraY);
			c.lineTo(this.path[0].px * FIELD_SIZE - game.cameraX, this.path[0].py * FIELD_SIZE - game.cameraY);
			for(var i = 0; i < this.queueOrder.length; i++)
				c.lineTo(this.queueTarget[i].px * FIELD_SIZE - game.cameraX, this.queueTarget[i].py * FIELD_SIZE - game.cameraY);
			c.stroke();
		}
	}
}