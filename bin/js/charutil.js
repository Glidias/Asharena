/**
 * ...
 * @author Glenn Ko
 */

// Utility methods

var PM_PRNG = function(){
    this.seed = 1;
}

/**
 * provides the next pseudorandom number
 * as an unsigned integer (31 bits)
 */
PM_PRNG.prototype.nextInt = function(){
    return this.gen();
}

PM_PRNG.prototype.MAX = 0x7fffffff;

/**
 * provides the next pseudorandom number
 * as a float between nearly 0 and nearly 1.0.
 */
PM_PRNG.prototype.nextDouble = function() {
    return (this.gen() / 2147483647);
}

/**
 * provides the next pseudorandom number
 * as a boolean
*/
PM_PRNG.prototype.nextBoolean = function(){
    return (this.gen() % 2) === 0;
}

/**
 * provides the next pseudorandom number
 * as an unsigned integer (31 bits) betweeen
 * a given range.
 */
PM_PRNG.prototype.nextIntRange = function(min, max){
    // min -= .4999;
    // max += .4999;
    return Math.round(min + ((max - min) * this.nextDouble()));
}

/**
 * provides the next pseudorandom number
 * as a float between a given range.
 */
PM_PRNG.prototype.nextDoubleRange = function(min, max){
    return min + ((max - min) * this.nextDouble());
}

PM_PRNG.prototype.gen = function(){
    //integer version 1, for max int 2^46 - 1 or larger.
    return this.seed = (this.seed * 16807) % 2147483647;

    /**
     * integer version 2, for max int 2^31 - 1 (slowest)
     */
    // var test = 16807 * (this.seed % 127773 >> 0) - 2836 * (this.seed / 127773 >> 0);
    // return this.seed = (test > 0 ? test : test + 2147483647);

    /**
     * david g. carta's optimisation is 15% slower than integer version 1
     */
    // var hi = 16807 * (this.seed >> 16);
    // var lo = 16807 * (this.seed & 0xFFFF) + ((hi & 0x7FFF) << 16) + (hi >> 15);
    // return this.seed = (lo > 0x7FFFFFFF ? lo - 0x7FFFFFFF : lo);
}

	
function createArrIdHash(arr) {
	var len = arr.length;
	var i;
	for (i=0; i<len; i++) {
		arr[arr[i].id] = arr[i];
	}
}

// Default Character classes

var CharClassGenList = [
	{
		"id":"knight"
		,"name":"Knight"
		,"attrStartBonus":{
			str: 3,
			dex: 0,
			spd: 0,
			con: 2,
			per: 0,
			intl: 0
		}
		,"weights": {
			str: 3,
			dex: 2,
			spd: .5,
			con: 2,
			per: .5,
			intl: .5
		}
		,"defaultArmour": 70
		,"defaultShield": 65
		,"skills": ["armour", "shield", "twoHandedMelee", "sword", "manAtArms", "willpower", "bodybuilding"]
		,"startSkills": ["armour", "shield", "2hMelee", "sword"]
		,"favskill": "armour"
	}
	,{
		"id":"bowman"
		,"name":"Bowman"
		,"attrStartBonus":{
			str: 0,
			dex: 2,
			spd: 0,
			con: 0,
			per: 3,
			intl: 0
		}
		,"weights": {
			str: .25,
			dex: 2,
			spd: .5,
			con: .25,
			per: 3,
			intl: .15
		}
		,"defaultArmour": 20
		,"defaultShield": 0
		,"skills": ["bow", "crossbow", "rangedTactics", "bodybuilding", "willpower", "ranger", "sword"]
		,"startSkills": ["longbow", "crossbow", "rangedTactics"]
		,"favskill": "rangedTactics"
	}
	/*
	,{
		"id":"armsman"
		,"name":"Armsman"
		,"attrStartBonus":{
		
		}
		,"weights": {
			
		}
	}
	*/
];
CharClassGenList.attrArray = ["str", "dex", "spd", "con", "per", "intl"];

createArrIdHash(CharClassGenList);  // create hash id lookup for array

// Skill Hash
var WARBAND_SKILLS = {
	"oneHandedMelee": {label: "One-handed Melee" }
	,"twoHandedMelee": {label: "Two-handed Melee" }
	,"dualWeilding": {label: "Dual Weilding Melee" }
	,"fireArms": {label: "Firearms" }
	,"archery": {label: "Archery" }
	,"rangedTactics": {label: "Ranged Tactics" }
	,"shield": {label: "Shield" }
	,"martial": {label: "Martial" }
	,"evasion": {label: "Evasion" }
	,"grenade": {label: "Grenade" }
	,"armour": {label: "Armour Specialist" }
	,"bodybuilding": {label: "Body Building" }
	,"willpower": {label: "Willpower" }
	,"manAtArms": {label: "Man-at-Arms" }
	,"scoundrel": {label: "Scoundrel" }
	,"ranger": {label: "Ranger" }
	,"hydrosophist": {label: "Hydrosophist" }
	,"aerotheurge": {label: "Aerotheurge" }
	,"pyrokinetic": {label: "Pyrokinetic" }
	,"geomancer": {label: "Geomancer" }
	,"spiritmagi": {label: "Spiritmagi" }
	,"bow": {label: "Bow" }
	,"crossbow": {label: "Crossbow" }
	,"dagger": {label: "Dagger" }
	,"sword": {label: "Sword" }
	,"axe": {label: "Axe" }
	,"spear": {label: "Spear" }
	,"blunt": {label: "Blunt Weapon" }
	,"staff": {label: "Staff" }
	,"shotgun": {label: "Shotgun" }
	,"rifle": {label: "Rifle" }
	
}

// Character generation util methods
var PRNG = new PM_PRNG();

var CharGenUtil = {
	createNewCharBase: function(obj, namer) {
		if (!obj) obj = {};
		obj.level = 1;
		obj.attr = {
			str: 5,
			dex: 5,
			spd: 5,
			con: 5,
			per: 5,
			intl: 5
		};
		
		obj.blockRating = 0;
		
		if (namer == null) namer = Math.floor( Math.random()*PRNG.MAX );
		if (typeof namer === "string") {
			// todo: convert name to string
			
		}
		
		obj.seed = namer;
		
		obj.startAttr = {
			str: obj.attr.str,
			dex: obj.attr.dex,
			spd: obj.attr.spd,
			con: obj.attr.con,
			per: obj.attr.per,
			intl: obj.attr.intl
		};
		
		obj.skills = [];
	

		
		return obj;
	}
	,reClassify: function(obj, classProps, isNew) {
		obj.classId = classProps.id;
		
		var i;
		var len;
		
		if (isNew) {
			var skills;
			len = classProps.favSkills;
			for (i=0; i< len; i++) {
				
			}
			obj.training = {};
			obj.skills = skills =  classProps.skills;
			len = skills.length;
			for (i=0; i <len; i++) {
				obj.training[skills[i]] = 0;
			}
			
			obj.armourRating = classProps.defaultArmour;
			obj.blockRating = classProps.defaultShield;
		}

		
		function recalculateWeights() {
            
  
            var totalDeclaredWeight = 0;
			var weight;
            for (i = 0; i < attrArray.length; i++) {
                weight = classProps.weights[attrArray[i]];
                 totalDeclaredWeight += weight;
            }
            
           return totalDeclaredWeight;
        }
		
		function getRandomIndex(randRatio, weights, WEIGHTS_TOTAL ) {
         // alert(weights);
           randRatio *= WEIGHTS_TOTAL;

            var accum = 0;
            var result = 0;
            var i;
            for ( i = 0; i < weights.length; i++) {    
                if (randRatio < accum) {  // did not meet requirement
                    break;
                }
                accum += weights[i];
				
                result = i;
            }
            
            return result;
        }
		
		var attrArray = CharClassGenList.attrArray;
		var total = recalculateWeights();
		
		PRNG.seed = obj.seed;
		var levelsProgressed = obj.level - 1;
		
        len = attrArray.length;
		
		var prop;
		var weights = [];
        for (i = 0; i < len; i++) {
			prop = attrArray[i];
            obj.attr[prop] =  obj.startAttr[prop] + classProps.attrStartBonus[prop];
			weights.push( classProps.weights[prop] );
        }
		
		
		
		
		for (i = 0; i < levelsProgressed; i++) {
		//	alert( total+","+weights+","+getRandomIndex(PRNG.nextDouble(), weights, total) );
            obj.attr[ attrArray[getRandomIndex(PRNG.nextDouble() , weights, total)] ]++;
        }
		
		
	}
	
};

	