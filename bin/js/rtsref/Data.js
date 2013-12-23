// Players
var players = [
	new Player("Player1", CONTROLLER.HUMAN, 0, 1000),
	new Player("Player2", CONTROLLER.COMPUTER, 1, 1000),
	new Player("Neutral", CONTROLLER.NONE, 2, 0)
];

var PLAYING_PLAYER = players[0];

// Units
var unitTypes = [
	
	new UnitType({
		"name": "Soldier",
		"hp": 100,
		"movementSpeed": 2.2,
		"weaponCooldown": 1.0,
		"weaponDelay": 0.2,
		"dmg": 9,
		"range": 0.2,
		"vision": 7,
		"circleSize": 0.43,
		"circleOffset": 0.25,
		"commandMask": [true, true, true, false, false, false, true, false, false, false],
		"buildTime": 25,
		"cost": 80,
		"healthbarOffset": 0.813,
		"healthbarWidth": 0.688,
		"imgPath": "imgs/units/soldier/",
		"description": "Soldiers are basic melee combat units."
	}),

	new UnitType({
		"name": "Rifleman",
		"hp": 60,
		"movementSpeed": 2.2,
		"weaponCooldown": 1.4,
		"weaponDelay": 0.2,
		"dmg": 6,
		"range": 5,
		"vision": 7,
		"circleSize": 0.43,
		"circleOffset": 0.25,
		"commandMask": [true, true, true, false, false, false, true, false, false, false],
		"buildTime": 30,
		"cost": 80,
		"healthbarOffset": 0.813,
		"healthbarWidth": 0.688,
		"imgPath": "imgs/units/rifleman/",
		"description": "Riflemen are weaker than Soldiers, but can shoot over distance."
	}),

	new UnitType({
		"name": "Worker",
		"hp": 55,
		"movementSpeed": 2.4,
		"weaponCooldown": 1.0,
		"weaponDelay": 0.2,
		"dmg": 5,
		"range": 0.2,
		"vision": 7,
		"circleSize": 0.43,
		"circleOffset": 0.25,
		"commandMask": [true, true, true, false, false, false, true, true, true, true],
		"buildTime": 25,
		"cost": 60,
		"healthbarOffset": 0.813,
		"healthbarWidth": 0.688,
		"imgPath": "imgs/units/worker/",
		"description": "Workers gather gold and construct buildings. They can also fight, but are not very good at it."
	})
	
];

// Buildings
var buildingTypes = [
	
	new BuildingType({
		"name": "Castle",
		"hp": 2000,
		"size": 4,
		"weaponCooldown": 1,
		"weaponDelay": 1,
		"dmg": 0,
		"range": 0,
		"vision": 10,
		"circleSize": 2.65,
		"circleOffset": 0.625,
		"commandMask": [false, false, false, true, false, false, false, false],
		"buildTime": 60,
		"cost": 450,
		"healthbarOffset": 3.25,
		"healthbarWidth": 2.5,
		"img": "imgs/buildings/cc-1.png",
		"img2": "imgs/buildings/cc-2.png",
		"constructionImg": "imgs/buildings/under-construction-cc.png",
		"description": "The Castle is your main building. It can train workers and is used to return gathered gold."
	}),

	new BuildingType({
		"name": "Barracks",
		"hp": 1000,
		"size": 3,
		"weaponCooldown": 1,
		"weaponDelay": 1,
		"dmg": 0,
		"range": 0,
		"vision": 9,
		"circleSize": 2.25,
		"circleOffset": 0.47,
		"commandMask": [false, false, false, false, true, true, false, false],
		"buildTime": 40,
		"cost": 350,
		"healthbarOffset": 3.44,
		"healthbarWidth": 2.03,
		"img": "imgs/buildings/barracks-1.png",
		"img2": "imgs/buildings/barracks-2.png",
		"constructionImg": "imgs/buildings/under-construction-rax.png",
		"description": "The Barracks can train Soldiers and Riflemen."
	}),

	new BuildingType({
		"name": "Watchtower",
		"hp": 500,
		"size": 2,
		"weaponCooldown": 1.8,
		"weaponDelay": 0.3,
		"dmg": 15,
		"range": 7,
		"vision": 12,
		"circleSize": 1.34,
		"circleOffset": 0.312,
		"commandMask": [true, true, false, false, false, false, false, false],
		"buildTime": 50,
		"cost": 250,
		"healthbarOffset": 3.69,
		"healthbarWidth": 1.56,
		"img": "imgs/buildings/tower-1.png",
		"img2": "imgs/buildings/tower-2.png",
		"constructionImg": "imgs/buildings/under-construction-tower.png",
		"description": "The Watchtower is a defensive structure, which shoots arrows at enemy units in range."
	}),

	new BuildingType({
		"name": "Goldmine",
		"hp": 4000000,
		"size": 3,
		"weaponCooldown": 1,
		"weaponDelay": 1,
		"dmg": 0,
		"range": 0,
		"vision": 0,
		"circleSize": 2.12,
		"circleOffset": 0.47,
		"commandMask": [false, false, false, false, false, false, false, false],
		"buildTime": 30,
		"cost": 250,
		"healthbarOffset": 2.15,
		"healthbarWidth": 2.031,
		"img": "imgs/buildings/mine.png",
		"img2": "imgs/buildings/mine.png",
		"constructionImg": "imgs/buildings/mine.png",
		"description": "The Goldmine contains gold for players to gather."
	})
	
];


// Tiles
var tileTypes = [
	
	new TileType({
		"name": "Tree 1",
		"img": "imgs/tiles/tree1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Tree 2",
		"img": "imgs/tiles/tree2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Tree 3",
		"img": "imgs/tiles/tree3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Tree 4",
		"img": "imgs/tiles/tree4.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Stone 1",
		"img": "imgs/tiles/stone1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Stone 2",
		"img": "imgs/tiles/stone2.png",
		"sizeX": 2,
		"sizeY": 2,
		"blocking": true
	}),
	
	new TileType({
		"name": "Stone 3",
		"img": "imgs/tiles/stone3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Stone 4",
		"img": "imgs/tiles/stone4.png",
		"sizeX": 2,
		"sizeY": 2,
		"blocking": true
	}),
	
	new TileType({
		"name": "Wall",
		"img": "imgs/tiles/wall.png",
		"sizeX": 2,
		"sizeY": 2,
		"blocking": true
	}),
	
	new TileType({
		"name": "Wall 2",
		"img": "imgs/tiles/wall2.png",
		"sizeX": 2,
		"sizeY": 2,
		"blocking": true
	}),
	
	new TileType({
		"name": "Wall 3",
		"img": "imgs/tiles/wall3.png",
		"sizeX": 2,
		"sizeY": 2,
		"blocking": true
	}),
	
	new TileType({
		"name": "Wall 4",
		"img": "imgs/tiles/wall4.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": true
	}),
	
	new TileType({
		"name": "Flower 2",
		"img": "imgs/tiles/flower2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Flower 3",
		"img": "imgs/tiles/flower3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Flower 4",
		"img": "imgs/tiles/flower4.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Flower 5",
		"img": "imgs/tiles/flower5.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Stone 8",
		"img": "imgs/tiles/stone8.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Stone 9",
		"img": "imgs/tiles/stone9.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Grass d 5",
		"img": "imgs/tiles/grass5.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Grass d 6",
		"img": "imgs/tiles/grass6.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Grass d 7",
		"img": "imgs/tiles/grass7.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Grass d 8",
		"img": "imgs/tiles/grass8.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Grass d 9",
		"img": "imgs/tiles/grass9.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Leaf 1",
		"img": "imgs/tiles/leaf1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Leaf 2",
		"img": "imgs/tiles/leaf2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Plant 1",
		"img": "imgs/tiles/plant1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	new TileType({
		"name": "Wood 1",
		"img": "imgs/tiles/wood1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDecoration": true
	}),
	
	
	// Grounds
	new TileType({
		"name": "Grass 1",
		"img": "imgs/tiles/ground1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Grass 2",
		"img": "imgs/tiles/ground2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Grass 3",
		"img": "imgs/tiles/ground3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Grass 4",
		"img": "imgs/tiles/ground4.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Grass 5",
		"img": "imgs/tiles/ground5.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 1",
		"img": "imgs/tiles/groundn1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 2",
		"img": "imgs/tiles/groundn2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 3",
		"img": "imgs/tiles/groundn3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 4",
		"img": "imgs/tiles/groundn4.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 5",
		"img": "imgs/tiles/groundn5.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 6",
		"img": "imgs/tiles/groundn6.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 7",
		"img": "imgs/tiles/groundn7.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 8",
		"img": "imgs/tiles/groundn8.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground n 9",
		"img": "imgs/tiles/groundn1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	
	new TileType({
		"name": "Ground n 10",
		"img": "imgs/tiles/groundn9.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isGround": true,
		"isDecoration": true
	}),
	
	
	new TileType({
		"name": "Ground e 1",
		"img": "imgs/tiles/groundn1.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground e 2",
		"img": "imgs/tiles/groundn2.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	}),
	
	new TileType({
		"name": "Ground e 3",
		"img": "imgs/tiles/groundn3.png",
		"sizeX": 1,
		"sizeY": 1,
		"blocking": false,
		"isDefault": true
	})

];


var SOLDIER = unitTypes[0];
var RIFLEMAN = unitTypes[1];
var WORKER = unitTypes[2];

var CC = buildingTypes[0];
var RAX = buildingTypes[1];
var TOWER = buildingTypes[2];
var MINE = buildingTypes[3];