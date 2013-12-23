function Game()
{
	this.pseudoBuildings = []; // buildings thar are ordered to build are here, they need to be drawed with lower alpha, but not used gameplay wise
	this.selectedUnits = [];
	this.blockArray = []; // false = blocked, true = free
	this.timeOfLastSelection = 0; // to check for double click on selection
	this.projectiles = [];
	this.fields = [];
	this.units = [];
	this.buildings = [];
	this.tiles = [];
	this.groundTiles = [];
	this.dyingUnits = [];
	this.effects = [];
	this.lastTickCircleEffect = 0;
	this.cameraX = 0;
	this.cameraY = 0;
	this.global_id = 1;
	this.minimap = null;
	this.env = new Enviroment();
	this.lastYesSound = -999; // tick of last time unit said "yes" sound (reaction to order)
	this.lastReadySound = -999; // tick of last time unit said "ready" sound (reaction to order)
	
	// create additional canvas groundtiles
	this.groundTilesCanvas = document.createElement('canvas');
}

// load a map
Game.prototype.loadMap = function(data)
{
	this.x = data.x;
	this.y = data.y;
	this.name = data.name;
	this.data = data;
	
	// reset ticksCounter (=Game timer)
	ticksCounter = 0;
	
	// reset storage for commands that will be sent and recieved
	incomingOrders = [];
	outgoingOrders = [];
	for(var i = 0; i < TICKS_DELAY; i++)
		outgoingOrders.push([i]);
	
	// set ground tiles canvas size depending on map size
	this.groundTilesCanvas.width = this.x * FIELD_SIZE / SCALE_FACTOR;
	this.groundTilesCanvas.height = this.y * FIELD_SIZE / SCALE_FACTOR;
	
	// reset interface
	interface.reset();
	
	// new keymanager (so control groups from possibli last game gets deleted)
	keyManager = new KeyManager();
	
	// initialize players
	for(var i = 0; i < players.length; i++)
		players[i].init();
	
	// fill block Array
	for(var x = 0; x <= this.x + 1; x++)
	{
		this.blockArray[x] = [];
		for(var y = 0; y <= this.y + 1; y++)
		{
			this.blockArray[x][y] = true;
			if(x < 1 || x > this.x || y < 1 || y > this.y) // if outside borders
				this.blockArray[x][y] = false;
		}
	}
	
	// fill fields Array
	for(var x = 1; x <= this.x; x++)
	{
		this.fields[x] = [];
		for(var y = 1; y <= this.y; y++)
			this.fields[x][y] = new Field(x, y);
	}
	
	// generate default ground tiles
	if(this.data.defaultTiles)
		for(var x = 1; x <= this.x; x++)
			for(var y = 1; y <= this.y; y++)
				new Tile({"x": x, "y": y, "type": this.data.defaultTiles[Math.floor(Math.random() * this.data.defaultTiles.length)].toTileType()});
	
	// create units and buildings and tiles
	for(var i = 0; i < data.units.length; i++)
		new Unit({"x": data.units[i].x, "y": data.units[i].y, "type": data.units[i].type.toUnitType(), "owner": data.units[i].owner.toPlayer()});
	
	for(var i = 0; i < data.buildings.length; i++)
		new Building({"x": data.buildings[i].x, "y": data.buildings[i].y, "type": data.buildings[i].type.toBuildingType(), "owner": data.buildings[i].owner.toPlayer()});
	
	for(var i = 0; i < data.tiles.length; i++)
	{
		var type = data.tiles[i].type.toTileType();
		new Tile({"x": data.tiles[i].x, "y": data.tiles[i].y, "type": type});
	}
	
	this.generateGroundTextureCanvas();
	
	// create Minimap
	this.minimap = new Minimap(this, 0, -MINIMAP_HEIGHT);
	
	// refresh all players vision
	for(var i = 0; i < players.length; i++)
		players[i].refreshVision();
	
	// find cc
	var cc = null;
	for(var k = 0; k < this.buildings.length; k++)
		if(this.buildings[k].type == CC && this.buildings[k].owner == PLAYING_PLAYER)
			cc = this.buildings[k];
	
	// set camera to cc position
	if(cc)
	{
		this.cameraX = cc.pos.px * FIELD_SIZE - WIDTH / 2;
		this.cameraY = cc.pos.py * FIELD_SIZE - HEIGHT / 2;
	}
}

Game.prototype.generateGroundTextureCanvas = function()
{
	for(var i = 0; i < this.groundTiles.length; i++)
	{
		var type = this.groundTiles[i].type;
		var img = type.getTitleImage();
		
		if(type.isDefault)
			this.groundTilesCanvas.getContext("2d").drawImage(img, (this.groundTiles[i].x - 1) * 16, (this.groundTiles[i].y - 1) * 16);
		else
			this.groundTilesCanvas.getContext("2d").drawImage(img, Math.floor(this.groundTiles[i].x * 16 - img.width / 2), Math.floor(this.groundTiles[i].y * 16 - img.height / 2));
	}
}

Game.prototype.export = function()
{
	var data = {"x": this.x, "y": this.y, "tiles": [], "groundTiles": [], "units": [], "buildings": [], "defaultTiles": ["Ground n 6", "Ground n 7", "Ground n 8", "Ground n 9", "Ground n 5", "Ground n 1", "Ground n 2", "Ground n 3", "Ground n 4"]};
	
	var tiles = this.tiles.concat(this.groundTiles);
	for(var i = 0; i < tiles.length; i++)
		if(!tiles[i].type.isDefault) // dont save default tiles (= ground textures), they are generated randomly at each mapload
		{
			if(tiles[i].type.isDecoration) // decoration tiles are stored with real coords (= pixel coords), and not field coords
				data.tiles.push({"x": tiles[i].pos.px, "y": tiles[i].pos.py, "type": tiles[i].type.name});
			else
				data.tiles.push({"x": tiles[i].x, "y": tiles[i].y, "type": tiles[i].type.name});
		}
	
	for(var i = 0; i < this.units.length; i++)
		data.units.push({"x": this.units[i].pos.px, "y": this.units[i].pos.py, "type": this.units[i].type.name, "owner": this.units[i].owner.number});
	
	for(var i = 0; i < this.buildings.length; i++)
		data.buildings.push({"x": this.buildings[i].x, "y": this.buildings[i].y, "type": this.buildings[i].type.name, "owner": this.buildings[i].owner.number});
	
	return data;
}

Game.prototype.getUnitById = function(id)
{
	var unitsAndBuildings = this.units.concat(this.buildings);
	for(var i = 0; i < unitsAndBuildings.length; i++)
		if(unitsAndBuildings[i].id == id)
			return unitsAndBuildings[i];
	return null;
}

Game.prototype.getNextBuildingOfType = function(pos, type, owner, onlyFinished)
{
	var shortestDistance = 999999;
	var building = null;
	for(var i = 0; i < this.buildings.length; i++)
		if(this.buildings[i].type == type && pos.distanceTo2(this.buildings[i].pos) < shortestDistance && (!owner || owner == this.buildings[i].owner) && (!onlyFinished || !this.buildings[i].isUnderConstruction))
		{
			building = this.buildings[i];
			shortestDistance = pos.distanceTo2(this.buildings[i].pos);
		}
	
	return building;
}

Game.prototype.getUnitsOfTypeOrderedByDistanceToPos = function(type, pos)
{
	var units = [];
	
	var unitsAndBuildings = this.units.concat(this.buildings);
	for(var i = 0; i < unitsAndBuildings.length; i++)
		if(unitsAndBuildings[i].type == type)
			units.push(unitsAndBuildings[i]);
	
	units = _.sortBy(units, function(unit){ return unit.pos.distanceTo(pos); });
	
	return units;
}

Game.prototype.getUnitsOfTypeOrderedByGroundDistanceToUnit = function(type, unit)
{
	var units = [];
	
	var unitsAndBuildings = this.units.concat(this.buildings);
	for(var i = 0; i < unitsAndBuildings.length; i++)
		if(unitsAndBuildings[i].type == type)
			units.push(unitsAndBuildings[i]);
	
	units = _.sortBy(units, function(unit2){ return unit.getPath(unit2.pos.x, unit2.pos.y).length; });
	
	return units;
}

Game.prototype.getNextPositionToMakeCCFromPosition = function(target, from)
{
	var checkPos = target;
	
	for(var i = 0; i < 20; i++)
	{
		if(CC.couldBePlacedAt(checkPos) && i < 20)
			return checkPos;
		checkPos = checkPos.addNormalizedVector(from, 1);
	}
	
	return null;
}

// find and return enemy unit in vision range with highest attack priority
Game.prototype.getHighestPrioEnemyUnitInRange = function(unit, range)
{
	var best = null;
	var bestDistance = range;
	var bestPrio = 0;
	var units = this.units.concat(this.buildings);
	
	for(var i = 0; i < units.length; i++)
	{
		var prio = units[i].getAttackPrio();
		var distance = unit.distanceTo(units[i]);
		if(unit != units[i] && unit.owner.isEnemyOfPlayer(units[i].owner) && distance <= range && (prio > bestPrio || (prio == bestPrio && distance < bestDistance)))
		{
			best = units[i];
			bestDistance = distance;
			bestPrio = prio;
		}
	}
	
	return best;
}

// get unit at specific position (usually to check if where we clicked is a unit and which one) or for hover effect (if vision is passed, only return visible units)
Game.prototype.getUnitAtPosition = function(x, y)
{
	var bestUnit = null;
	var lowestDistance = 99999;
	var clickedField = new Field(x, y, true);
	for(var i = 0; i < this.units.length; i++)
		if(this.units[i].isInBox(x - CLICK_TOLERANCE, y - CLICK_TOLERANCE, x + CLICK_TOLERANCE, y + CLICK_TOLERANCE) && lowestDistance > this.units[i].pos.distanceTo2(clickedField) && PLAYING_PLAYER.canSeeUnit(this.units[i]))
		{
			lowestDistance = this.units[i].pos.distanceTo2(clickedField);
			bestUnit = this.units[i];
		}
	
	if(bestUnit)
		return bestUnit;
	
	lowestDistance = 99999;
	for(var i = 0; i < this.buildings.length; i++)
		if(this.buildings[i].isInBox(x - CLICK_TOLERANCE, y - CLICK_TOLERANCE, x + CLICK_TOLERANCE, y + CLICK_TOLERANCE) && lowestDistance > this.buildings[i].pos.distanceTo2(clickedField) && PLAYING_PLAYER.canSeeUnit(this.buildings[i]))
		{
			lowestDistance = this.buildings[i].pos.distanceTo2(clickedField);
			bestUnit = this.buildings[i];
		}
	return bestUnit;
}

// selects units based on the coordinate (if strg == true and single click, select all units of this type) (if shift, add to selection instead of replace selection)
Game.prototype.selectUnits = function(x1, y1, x2, y2, strg, shift)
{
	var x1n = Math.min(x1, x2);
	var x2n = Math.max(x1, x2);
	var y1n = Math.min(y1, y2);
	var y2n = Math.max(y1, y2);
	
	// if click (no box), then look for nearest valiable unit and select this one
	if(x2n - x1n <= 0.05 && y2n - y1n <= 0.05)
	{
		var newUnit = this.getUnitAtPosition(x1n, y1n);
		// if strg+click or doubleclick
		if(newUnit && newUnit.owner.isControllable() && (strg || (this.selectedUnits.length == 1 && this.selectedUnits[0] == newUnit && this.timeOfLastSelection + 500 >= timestamp)))
		{
			var unitsAndBuildings = this.units.concat(this.buildings);
			var newUnits = [];
			for(var i = 0; i < unitsAndBuildings.length; i++)
				if(unitsAndBuildings[i].isInBox(0, 0, WIDTH, HEIGHT - INTERFACE_HEIGHT) && unitsAndBuildings[i].type == newUnit.type && unitsAndBuildings[i].owner.isControllable())
					newUnits.push(unitsAndBuildings[i]);
			this.selectedUnits = newUnits.length > 0 ? newUnits : this.selectedUnits;
		}
		else if(newUnit)
		{
			if(!shift)
			{
				this.selectedUnits = [newUnit];
				this.timeOfLastSelection = timestamp;
			}
			else
				this.addUnitsToSelection([newUnit]);
		}
		return;
	}
	
	var newSelectedUnits = [];
	var countEnemyUnitsSelected = 0; // also buildings
	var countOwnUnitsSelected = 0; // also buildings
	var countOwnBildingsSelected = 0;
	var unitsAndBuildings = this.units.concat(this.buildings);
	for(var i = 0; i < unitsAndBuildings.length; i++)
		if(unitsAndBuildings[i].isInBox(x1n, y1n, x2n, y2n))
		{
			newSelectedUnits.push(unitsAndBuildings[i]);
			countEnemyUnitsSelected += !unitsAndBuildings[i].owner.isControllable() ? 1 : 0;
			countOwnUnitsSelected += unitsAndBuildings[i].owner.isControllable() ? 1 : 0;
			countOwnBildingsSelected += (unitsAndBuildings[i].owner.isControllable() && unitsAndBuildings[i].type.isBuilding) ? 1 : 0;
		}
	
	// if own and enemy units selected, unselect all enemy units
	if(countOwnUnitsSelected > 0 && countEnemyUnitsSelected > 0)
		for(var i = 0; i < newSelectedUnits.length; i++)
			if(!newSelectedUnits[i].owner.isControllable())
			{
				newSelectedUnits.splice(i, 1);
				i--;
			}

	// if no own but more than 1 enemy units selected, unselect all but 1 enemy units
	if(countOwnUnitsSelected == 0 && countEnemyUnitsSelected > 0)
		newSelectedUnits = [newSelectedUnits[0]];
	
	// if only buildings selected, unselect all but 1
	if(newSelectedUnits.length > 1 && countOwnBildingsSelected == newSelectedUnits.length)
		newSelectedUnits.length = 1;
	
	// if buildings but also units selected, unselect all buildings
	if(countOwnBildingsSelected > 0 && countOwnUnitsSelected - countOwnBildingsSelected > 0)
		for(var i = 0; i < newSelectedUnits.length; i++)
			if(newSelectedUnits[i].type.isBuilding)
			{
				newSelectedUnits.splice(i, 1);
				i--;
			}
	
	// store new array, but only if units have been selected. Otherwise keep old selection; if shift, add instead of replace
	if(!shift)
		this.selectedUnits = newSelectedUnits.length > 0 ? newSelectedUnits : this.selectedUnits;
	else
		this.addUnitsToSelection(newSelectedUnits);
}

Game.prototype.addUnitsToSelection = function(newUnits)
{
	// if no new units, nothing to do
	if(newUnits.length == 0)
		return;
	
	// if no existing units, just replace selected units with the new units
	if(this.selectedUnits.length == 0)
	{
		this.selectedUnits = newUnits;
		return;
	}
	
	if(newUnits[0].owner.isControllable() && this.selectedUnits[0].owner.isControllable())
		if(this.selectedUnits[0].type.isBuilding && newUnits[0].type.isBuilding || !this.selectedUnits[0].type.isBuilding && !newUnits[0].type.isBuilding)
		{
			for(var i = 0; i < newUnits.length; i++)
			{
				var contains = false;
				for(var k = 0; k < this.selectedUnits.length; k++)
					if(newUnits[i] == this.selectedUnits[k])
						contains = true;
				if(!contains)
					this.selectedUnits.push(newUnits[i]);
			}
		}
}

// check if the current selected units are human (= not cpu)
Game.prototype.humanUnitsSelected = function()
{
	return this.selectedUnits.length > 0 && this.selectedUnits[0].owner.controller == CONTROLLER.HUMAN;
}

// return all unblocked neightbour nodes
Game.prototype.getNBNodes = function(x, y)
{
	var nbs = [];
	if(this.blockArray[x][y - 1])
		nbs.push(this.fields[x][y - 1]);
	if(this.blockArray[x - 1][y])
		nbs.push(this.fields[x - 1][y]);
	if(this.blockArray[x + 1][y])
		nbs.push(this.fields[x + 1][y]);
	if(this.blockArray[x][y + 1])
		nbs.push(this.fields[x][y + 1]);
	
	if(this.blockArray[x - 1][y - 1] && this.blockArray[x][y - 1] && this.blockArray[x - 1][y])
		nbs.push(this.fields[x - 1][y - 1]);
	if(this.blockArray[x + 1][y - 1] && this.blockArray[x][y - 1] && this.blockArray[x + 1][y])
		nbs.push(this.fields[x + 1][y - 1]);
	if(this.blockArray[x - 1][y + 1] && this.blockArray[x][y + 1] && this.blockArray[x - 1][y])
		nbs.push(this.fields[x - 1][y + 1]);
	if(this.blockArray[x + 1][y + 1] && this.blockArray[x][y + 1] && this.blockArray[x + 1][y])
		nbs.push(this.fields[x + 1][y + 1]);
	return nbs;
}

Game.prototype.fieldIsBlocked = function(x, y)
{
	return !(x > 0 && x <= this.x && y > 0 && y <= this.y && this.blockArray[x][y]);
}

Game.prototype.getCenterOfUnits = function(units)
{
	var center = new Field(0, 0, true);
	for(var i = 0; i < units.length; i++)
		center = center.add(units[i].pos);
	return new Field(center.px / units.length, center.py / units.length, true);
}

// return true, if at least one of the current selected units can perform a specific order
Game.prototype.selectedUnitsCanPerformOrder = function(order)
{
	for(var i = 0; i < this.selectedUnits.length; i++)
	{
		if(this.selectedUnits[i].type.commandMask[order] && (!this.selectedUnits[i].type.isBuilding || !this.selectedUnits[i].isUnderConstruction))
			return true;
		
		if(order == COMMAND.CANCEL && this.selectedUnits[i].type.isBuilding && (this.selectedUnits[i].isUnderConstruction || this.selectedUnits[i].queue[0]))
			return true;
	}
	
	return false;
}

Game.prototype.issueOrderToUnits = function(units, order, target, executeNow, shift)
{
	// if playing network game, add orders to array which will be later send to the server
	if(network_game && !executeNow)
	{
		// make array with target and order
		var newOrders;
		if(!target)
			newOrders = ["instant", order, shift];
		else if(target.isField)
			newOrders = ["field", order, shift, target.px, target.py];
		else
			newOrders = ["unit", order, shift, target.id];
		
		// add all the selected units
		for(var i = 0; i < units.length; i++)
			newOrders.push(units[i].id);
		
		// add to outgoing orders
		outgoingOrders[outgoingOrders.length - 1] = outgoingOrders[outgoingOrders.length - 1].concat(newOrders);
		
		return;
	}
	
	if((order == COMMAND.ATTACK || order == COMMAND.MOVETO) && units.length > 0 && units[0].owner.controller == CONTROLLER.HUMAN)
		target.blink();
	
	if(order == COMMAND.IDLE || order == COMMAND.HOLDPOSITION || order == COMMAND.ATTACK || order == COMMAND.CANCEL)
		for(var i = 0; i < units.length; i++)
			if(units[i] != target)
				units[i].issueOrder(order, target, false, shift);
	
	if((order == COMMAND.MOVE || order == COMMAND.AMOVE) && units.length > 0)
	{
		if(units[0].type.isBuilding)
		{
			for(var i = 0; i < units.length; i++)
				units[i].waypoint = target;
			return;
		}
		
		var center = this.getCenterOfUnits(units);
		var maxDist = 0;
		for(var i = 0; i < units.length; i++)
			maxDist = Math.max(maxDist, units[i].pos.distanceTo2(center));
		
		if(maxDist < 2.5 && maxDist < center.distanceTo2(target))
			for(var i = 0; i < units.length; i++)
				units[i].issueOrder(order, target.add(center.vectorTo(units[i].pos)), false, shift);
		else
			for(var i = 0; i < units.length; i++)
				units[i].issueOrder(order, target, false, shift);
		
		if(units.length > 0 && units[0].owner.controller == CONTROLLER.HUMAN)
			this.effects.push(new GroundOrder(target.px, target.py + Y_OFFSET));
	}
	
	if(order == COMMAND.MAKEWORKER || order == COMMAND.MAKESOLDIER || order == COMMAND.MAKERIFLEMAN)
	{
		// find building which can make this unit and has lowest building queue
		var bestValue = 99999999;
		var bestUnit = null;
		for(var i = 0; i < units.length; i++)
			if(units[i].type.commandMask[order] && !units[i].isUnderConstruction)
			{
				var value = 0;
				for(var k = 0; k < 5; k++)
					value += units[i].queue[k] ? 1000000 : 0;
				value += units[i].queue[0] ? units[i].queueTimeLeft : 0;
				if(value < bestValue)
				{
					bestValue = value;
					bestUnit = units[i];
				}
			}
		if(bestUnit)
			bestUnit.orderMake(getUnitTypeFromCommand(order));
	}
	
	if(order == COMMAND.MAKECC || order == COMMAND.MAKERAX || order == COMMAND.MAKETOWER)
	{
		// check which of the selected units that can execute the order is the closest one
		var bestUnit = null;
		var closestDistance = 999999;
		for(var i = 0; i < units.length; i++)
			if(units[i].type.commandMask[order] && units[i].pos.distanceTo(target) + ((units[i].order == COMMAND.MAKECC || units[i].order == COMMAND.MAKERAX || units[i].order == COMMAND.MAKETOWER) ? 9999 : 0) < closestDistance)
			{
				closestDistance = units[i].pos.distanceTo(target) + ((units[i].order == COMMAND.MAKECC || units[i].order == COMMAND.MAKERAX || units[i].order == COMMAND.MAKETOWER) ? 999 : 0);
				bestUnit = units[i];
			}
		if(bestUnit)
			bestUnit.issueOrder(order, target, false, shift);
	}
	
	if(order == COMMAND.MOVETO && units.length > 0)
	{
		if(units[0].type.isBuilding)
		{
			for(var i = 0; i < units.length; i++)
				units[i].waypoint = target;
			return;
		}
		
		for(var i = 0; i < units.length; i++)
			if(units[i].type == WORKER && (target.type == MINE || (target.type == CC && units[i].carriesGold))) // if unit == worker and target == goldmine or cc
				units[i].issueOrder(COMMAND.MINE, target, false, shift);
			else
				units[i].issueOrder(COMMAND.MOVETO, target, false, shift);
	}
}

Game.prototype.update = function()
{
	// update all players
	for(var i = 0; i < players.length; i++)
		players[i].update();
	
	for(var i = 0; i < this.units.length; i++)
		this.units[i].lastFramesPosition = new Field(this.units[i].pos.px, this.units[i].pos.py, true);
	
	// update all units
	for(var i = 0; i < this.units.length; i++)
		this.units[i].update();
	
	// check push prios of all units
	for(var i = 0; i < this.units.length; i++)
		this.units[i].checkPushPrio();
	
	// aftermove
	for(var i = 0; i < this.units.length; i++)
		this.units[i].afterMove();
	
	// update all buildings
	for(var i = 0; i < this.buildings.length; i++)
		this.buildings[i].update();
	
	// update projectiles
	for(var i = 0; i < this.projectiles.length; i++)
		if(!this.projectiles[i].update())
		{
			this.projectiles.splice(i, 1);
			i--;
		}
	
	// deselect units that are not visible
	for(var i = 0; i < this.selectedUnits.length; i++)
		if(!PLAYING_PLAYER.canSeeUnit(this.selectedUnits[i]))
		{
			this.selectedUnits.splice(i, 1);
			i--;
		}
}

Game.prototype.draw = function()
{
	// Scrolling
	var mouseScrollEnabled = document.fullScreen || document.mozFullScreen || document.webkitIsFullScreen || mouse_scroll_when_window_mode;
	if(keyManager.keys[KEY.DOWN] || keyManager.y >= HEIGHT - SCROLL_RANGE && mouseScrollEnabled)
		this.cameraY += timeDiff * SCROLL_SPEED;
	if(keyManager.keys[KEY.UP] || keyManager.y <= SCROLL_RANGE && mouseScrollEnabled)
		this.cameraY -= timeDiff * SCROLL_SPEED;
	if(keyManager.keys[KEY.LEFT] || keyManager.x <= SCROLL_RANGE && mouseScrollEnabled)
		this.cameraX -= timeDiff * SCROLL_SPEED;
	if(keyManager.keys[KEY.RIGHT] || keyManager.x >= WIDTH - SCROLL_RANGE && mouseScrollEnabled)
		this.cameraX += timeDiff * SCROLL_SPEED;
	
	// Minimap klick change screen
	if(keyManager.minimapScroll && keyManager.x < MINIMAP_WIDTH && keyManager.y > HEIGHT - MINIMAP_HEIGHT)
	{
		var field = this.minimap.getFieldFromClick(keyManager.x, keyManager.y);
		
		this.cameraX = Math.floor(field.px * FIELD_SIZE - WIDTH / 2);
		this.cameraY = Math.floor(field.py * FIELD_SIZE - HEIGHT / 2);
	}
	
	// if camera is out of bounds, bring it back
	this.cameraX = Math.floor(Math.min(this.cameraX, this.x * FIELD_SIZE - WIDTH));
	this.cameraY = Math.floor(Math.min(this.cameraY, this.y * FIELD_SIZE - HEIGHT + (game_state == GAME.EDITOR ? 200 : INTERFACE_HEIGHT)));
	this.cameraX = Math.floor(Math.max(this.cameraX, 0));
	this.cameraY = Math.floor(Math.max(this.cameraY, 0));
	
	var unitsBuildings = this.buildings.concat(this.units);
	
	// draw GroundTiles
	var h = HEIGHT - (game_state == GAME.EDITOR ? 200 : INTERFACE_HEIGHT);
	c.drawImage(this.groundTilesCanvas, this.cameraX / SCALE_FACTOR, this.cameraY / SCALE_FACTOR, WIDTH / SCALE_FACTOR, h / SCALE_FACTOR, 0, 0, WIDTH, h);
	
	// calculate exact drawing positions (interpolate between real positions)
	for(var i = 0; i < this.units.length; i++)
		this.units[i].updateDrawPosition();
	
	// draw unit blinking circles (has been rightclicked)
	for(var i = 0; i < unitsBuildings.length; i++)
		if(unitsBuildings[i].lastBlinkStart + 1600 > timestamp && (timestamp - unitsBuildings[i].lastBlinkStart) % 300 < 200)
			drawCircle(unitsBuildings[i].drawPos.px * FIELD_SIZE - this.cameraX, (unitsBuildings[i].drawPos.py + unitsBuildings[i].type.circleOffset) * FIELD_SIZE - this.cameraY, unitsBuildings[i].type.circleSize * FIELD_SIZE, unitsBuildings[i].owner.getAllyColor());
	
	// draw Unit Circles
	for(var i = 0; i < this.selectedUnits.length; i++)
		if(this.selectedUnits[i].isInBox(0, 0, WIDTH, HEIGHT))
			drawCircle(this.selectedUnits[i].drawPos.px * FIELD_SIZE - this.cameraX, (this.selectedUnits[i].drawPos.py + this.selectedUnits[i].type.circleOffset) * FIELD_SIZE - this.cameraY, this.selectedUnits[i].type.circleSize * FIELD_SIZE, this.selectedUnits[i].owner.getAllyColor());
		
	// draw hover circle(s)
	if(keyManager.drawBox)
	{
		var x1n = Math.min(keyManager.x, keyManager.startX);
		var x2n = Math.max(keyManager.x, keyManager.startX);
		var y1n = Math.min(keyManager.y, keyManager.startY);
		var y2n = Math.max(keyManager.y, keyManager.startY);
		for(var i = 0; i < unitsBuildings.length; i++)
			if(unitsBuildings[i].isInBox((x1n + this.cameraX) / FIELD_SIZE, (y1n + this.cameraY) / FIELD_SIZE, (x2n + this.cameraX) / FIELD_SIZE, (y2n + this.cameraY) / FIELD_SIZE) && PLAYING_PLAYER.canSeeUnit(unitsBuildings[i]))
				drawCircle(unitsBuildings[i].drawPos.px * FIELD_SIZE - this.cameraX, (unitsBuildings[i].drawPos.py + unitsBuildings[i].type.circleOffset) * FIELD_SIZE - this.cameraY, unitsBuildings[i].type.circleSize * FIELD_SIZE + 4, unitsBuildings[i].owner.getAllyColor());
	}
	else
	{
		var hoverUnit = this.getUnitAtPosition((keyManager.x + this.cameraX) / FIELD_SIZE, (keyManager.y + this.cameraY) / FIELD_SIZE);
		if(hoverUnit)
			drawCircle(hoverUnit.drawPos.px * FIELD_SIZE - this.cameraX, (hoverUnit.drawPos.py + hoverUnit.type.circleOffset) * FIELD_SIZE - this.cameraY, hoverUnit.type.circleSize * FIELD_SIZE + 4, hoverUnit.owner.getAllyColor());
	}
	
	// draw all objects (sort by y coordinate)
	objectsToDraw = _.sortBy(unitsBuildings.concat(this.pseudoBuildings, this.effects, this.tiles, this.dyingUnits), function(obj){ return -obj.pos.py; });
	while(objectsToDraw.length > 0)
	{
		var objectToDraw = objectsToDraw.pop();
		if(!objectToDraw.draw() && objectToDraw.isEffect)
			this.effects.erease(objectToDraw);
	}
	
	// draw health bars
	for(var i = 0; i < unitsBuildings.length; i++)
	{
		var unit = unitsBuildings[i];
		if(PLAYING_PLAYER.canSeeUnit(unit) && unit.type != MINE)
			unit.drawHealthbar((unit.drawPos.px - unit.type.healthbarWidth / 2) * FIELD_SIZE - game.cameraX, (unit.drawPos.py - unit.type.healthbarOffset) * FIELD_SIZE - game.cameraY, unit.type.healthbarWidth * FIELD_SIZE, 0.125 * FIELD_SIZE);
	}
	
	// draw waypoints
	c.lineWidth = 1.5;
	c.strokeStyle = "rgba(255, 255, 255, " + (1 - ((timestamp / 1000) % 0.8) * 0.8) + ")";
	if(this.humanUnitsSelected() && this.selectedUnits[0].type.isBuilding)
		for(var i = 0; i < this.selectedUnits.length; i++)
		{
			var unit = this.selectedUnits[i];
			
			if(unit.waypoint && unit.canProduceUnits())
			{
				var point = unit.waypoint.pos ? unit.waypoint.pos : unit.waypoint;
				
				c.beginPath();
				c.moveTo(unit.pos.px * FIELD_SIZE - game.cameraX, (unit.pos.py + unit.type.circleOffset / 2) * FIELD_SIZE - game.cameraY);
				c.lineTo(point.px * FIELD_SIZE - game.cameraX, (point.py + Y_OFFSET) * FIELD_SIZE - game.cameraY);
				c.stroke();
				
				// circle effect
				if(ticksCounter % 8 == 0 && unit.lastTickCircleEffect != ticksCounter)
				{
					this.effects.push(new GroundOrder(point.px, point.py + Y_OFFSET));
					unit.lastTickCircleEffect = ticksCounter;
				}
			}
			
		}
	
	// queued paths
	c.lineWidth = 1.5;
	c.strokeStyle = "rgba(255, 255, 255, 0.5)";
	if(this.humanUnitsSelected() && this.selectedUnits[0].type.isUnit)
		for(var i = 0; i < this.selectedUnits.length; i++)
			if(this.selectedUnits[i].queueOrder.length > 0)
			{
				var unit = this.selectedUnits[i];
				
				var targetsArray = [unit.pos];
				if(unit.path[0])
					targetsArray.push(unit.path[0]);
				
				for(var k = 0; k < unit.queueOrder.length; k++)
					targetsArray.push(unit.queueTarget[k].isField ? unit.queueTarget[k] : unit.queueTarget[k].pos);
				
				for(var k = 1; k < targetsArray.length; k++)
				{
					c.beginPath();
					c.moveTo(targetsArray[k - 1].px * FIELD_SIZE - game.cameraX, (targetsArray[k - 1].py + Y_OFFSET) * FIELD_SIZE - game.cameraY);
					c.lineTo(targetsArray[k].px * FIELD_SIZE - game.cameraX, (targetsArray[k].py + Y_OFFSET) * FIELD_SIZE - game.cameraY);
					c.stroke();
				}
				
				// circle effect
				if(ticksCounter % 8 == 0 && unit.lastTickCircleEffect != ticksCounter)
				{
					this.effects.push(new GroundOrder(targetsArray[targetsArray.length - 1].px, targetsArray[targetsArray.length - 1].py + Y_OFFSET));
					unit.lastTickCircleEffect = ticksCounter;
				}
			}
	
	// draw projectiles
	for(var i = 0; i < this.projectiles.length; i++)
		this.projectiles[i].draw();
	
	// vision
	c.fillStyle = "rgba(0, 0, 0, 0.4)";
	var startField = new Field(Math.floor(this.cameraX / FIELD_SIZE + 1), Math.floor(this.cameraY / FIELD_SIZE + 1), true);
	for(var x = startField.x; x < Math.min(startField.x + WIDTH / FIELD_SIZE + 1, this.x + 1); x++)
		for(var y = startField.y; y < startField.y + HEIGHT / FIELD_SIZE; y++)
		{
			if(!PLAYING_PLAYER.mask[x][y])
				c.fillRect(Math.floor(x * FIELD_SIZE - FIELD_SIZE - this.cameraX), Math.floor(y * FIELD_SIZE - FIELD_SIZE - this.cameraY), FIELD_SIZE, FIELD_SIZE);
		}
	
	// draw environment
	this.env.draw();
	
	// draw minimap
	this.minimap.draw();
}