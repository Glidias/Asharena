package saboteur.util 
{

	import flash.utils.Dictionary;
	/**
	 * Utility for Saboteur building path rules to support both Saboteur-1 and 2.
	 * @author Glenn Ko
	 */
	public class SaboteurPathUtil {
	
	  // standard mask values  (fill regions paths)
        public static const EAST:uint = (1 << 0);  
        public static const NORTH:uint = (1 << 1);
        public static const WEST:uint = (1 << 2);
        public static const SOUTH:uint = (1 << 3);
        
        public static const NORTHEAST:uint = (1 << 0);
        public static const NORTHWEST:uint = (1 << 1);
        public static const SOUTHWEST:uint = (1 << 2);
        public static const SOUTHEAST:uint = (1 << 3);

        public static const NORTH_EAST:uint = (NORTH | EAST);
        public static const NORTH_WEST:uint = (NORTH | WEST);
        public static const SOUTH_WEST:uint = (SOUTH | WEST);
        public static const SOUTH_EAST:uint = (SOUTH | EAST);
		public static const ALL_SIDES:uint = (NORTH | EAST | WEST | SOUTH);
        
        public static const ARC_VERTICAL:uint = (1 << 0);
        public static const ARC_HORIZONTAL:uint = (1 << 1);
        public static const ARC_NORTH_EAST:uint = (1 << 2);
        public static const ARC_NORTH_WEST:uint = (1 << 3);
        public static const ARC_SOUTH_WEST:uint = (1 << 4);
        public static const ARC_SOUTH_EAST:uint = (1 << 5);
        
		 static public const ARC_SHIFT:uint = 4;
        public static const ARC_MASK:uint =  (ARC_VERTICAL | ARC_HORIZONTAL | ARC_NORTH_EAST | ARC_NORTH_WEST | ARC_SOUTH_WEST | ARC_SOUTH_EAST) << ARC_SHIFT;  // originally ~15;
       
		
		// Saboteur 2 flags
		public static const SABO2_DOOR_GREEN:uint = (1 << 0);
        public static const SABO2_DOOR_BLUE:uint = (1 << 1);
        public static const SABO2_CRYSTAL:uint = (1 << 2);
        public static const SABO2_TUNNEL:uint = (1 << 3); // assumes tunnel goes horizontal always as per Saboteur convention
        public static const SABO2_LADDER:uint = (1 << 4);
		
		static public const SABO2_DOOR_MASK:uint = (SABO2_DOOR_GREEN | SABO2_DOOR_BLUE);
	    static public const SABO2_SHIFT:uint = ARC_SHIFT + 6;
		static public const SABO2_MASK:uint =  (SABO2_DOOR_GREEN | SABO2_DOOR_BLUE | SABO2_CRYSTAL | SABO2_TUNNEL | SABO2_LADDER ) << SABO2_SHIFT;
		 
    
        // predicted: 2^5 (standard 90deg east,north,west,south,center mask) = 32
        // + 8 (diagonal steer bendey cards, 2 steering mirrors and 6 with-orphan portions included)
        // + 6 (vertical flip cases of diagonal steer bendey cards above 8-2=6, since 2 steering mirrors can't flip vertically) +
        // + 6 ( horizontal and vertical striaght road with stray bit at side) 
        // + 4 (t junction with orphan edge bit) 
        // -1  (empty standard case) 
        // -1 (standard center cell only filled ) = 54
        // -4  (standard single edge with center filled) (merely deeper end, achieves same purpose)
        // = 50!
        
        public var combinations:Vector.<uint> = new Vector.<uint>();
		
		private var arcEdgeDict:Dictionary = new Dictionary();
		
		
		public static const RESULT_OUT:int = 0;  // no neighbor or path
		public static const RESULT_INVALID:int = -1;  // can't connect validly
		public static const RESULT_VALID:int = 1;  
		public static const RESULT_OCCUPIED:int = -2;  
		
		
		
		
		
		public function getValidResult(buildDict:Dictionary, east:int, south:int, value:uint, pathGraph:SaboteurGraph):int {
			if (buildDict[getGridKey(east, south)] != null) return RESULT_OCCUPIED;
			var toNorth:uint = getGridKey(east, south - 1);
			var toSouth:uint = getGridKey(east, south + 1);
			var toWest:uint = getGridKey(east-1, south);
			var toEast:uint = getGridKey(east + 1, south);
			var neighborFlags:uint = 0;
			neighborFlags |= buildDict[toEast] != null ? EAST : 0;
			neighborFlags |= buildDict[toNorth] != null ? NORTH : 0;
			neighborFlags |= buildDict[toWest] != null ? WEST : 0;
			neighborFlags |= buildDict[toSouth] != null ? SOUTH : 0;
			
			if (neighborFlags == 0) return RESULT_OUT;
			
			
			
			// must have connecting node
			var neighborVal:uint;
			if (neighborFlags & EAST) {
				
				neighborVal = buildDict[toEast];
				if ( ((value & EAST) != 0) != ((neighborVal & WEST) != 0) ) return RESULT_INVALID;
			}
			if (neighborFlags & WEST) {
	
				neighborVal = buildDict[toWest];
				if ( ((value & WEST) != 0) != ((neighborVal & EAST) != 0) ) return RESULT_INVALID;
			}
				if (neighborFlags & NORTH) {
				neighborVal = buildDict[toNorth];
				if ( ((value & NORTH) != 0) != ((neighborVal & SOUTH) != 0) ) return RESULT_INVALID;
			}
			if (neighborFlags & SOUTH) {
				neighborVal = buildDict[toSouth];
				if ( ((value & SOUTH) != 0) != ((neighborVal & NORTH) != 0) ) return RESULT_INVALID;
			}
			
			///*
			if (pathGraph != null) {  
		
			//	var arc:uint = getArcValue(value);
				if ( (neighborFlags & EAST) && pathGraph.endPoints[toEast] != null  && ((getTailEndArcVal(pathGraph.graphGrid[toEast].val)  & SaboteurGraph.ARC_WEST_MASK))  ) return RESULT_VALID; //
				if ( (neighborFlags & WEST) && pathGraph.endPoints[toWest] != null && ((getTailEndArcVal(pathGraph.graphGrid[toWest].val) & SaboteurGraph.ARC_EAST_MASK)  ) ) return RESULT_VALID;  // 
				if ( (neighborFlags & NORTH) && pathGraph.endPoints[toNorth] != null && ((getTailEndArcVal(pathGraph.graphGrid[toNorth].val) & SaboteurGraph.ARC_SOUTH_MASK)) ) return RESULT_VALID; //
				if ( (neighborFlags & SOUTH) && pathGraph.endPoints[toSouth] != null && ((getTailEndArcVal(pathGraph.graphGrid[toSouth].val) & SaboteurGraph.ARC_NORTH_MASK)) ) return RESULT_VALID; //
				// special indicator for above case to show no true path
				//throw new Error("Should have neighbor at least!" + ", "+pathGraph.endPoints[toNorth] + "/"+buildDict[toNorth] + ", "+pathGraph.endPoints[toSouth] + "/"+ buildDict[toSouth]);
				return RESULT_OUT;
			}
		//	*/
			
			return RESULT_VALID;
		}
		
		private function flip4Bits(c:uint):uint {  // flip 1st half and 2nd half 
			return (((c & 12) >> 2) | ((c & 3) << 2));
		}
		
		public function getFlipValue(val:uint):uint {
			//var referVal:uint = val;
			
			var edge:uint = getEdgeValue(val);
			var arcs:uint = getArcValue(val);
			
			edge = flip4Bits(edge);
			
		//	/*
			var arcHorizVert:uint = arcs & 3;
			arcs = (arcs >> 2);
			arcs = flip4Bits(arcs);
			arcs = (arcs << 2) | arcHorizVert;
			
		//	*/
			val = getValue(edge, arcs);
			
			
			return val;
		}
		
		private function getTailEndArcVal(val:Array):uint {
			
			return (val[val.length - 1] & ARC_MASK) >> ARC_SHIFT;
		}
		
		private static const INT_LIMIT:int = Math.sqrt(int.MAX_VALUE) * .5;

		private var _dictValueToIndex:Dictionary;
		
		public function getGridKey(east:int, south:int):uint {
			
			return (south + INT_LIMIT) * INT_LIMIT * 2 + (east + INT_LIMIT);
		}
		
		public function getEast(value:uint):int {
			return (value / (INT_LIMIT * 2)) - INT_LIMIT;
		}
		public function getSouth(value:uint):int {
			return (value % (INT_LIMIT * 2)) - INT_LIMIT;
		}
		
		public function buildAt(dict:Dictionary, east:int, south:int, value:uint):void {
			dict[getGridKey(east, south)] = value;
		}
		
		public function getValue(availableSides:uint, availableArcs:uint, sabo2:uint=0):uint {
			return availableSides | (availableArcs << ARC_SHIFT) | (sabo2 << SABO2_SHIFT);
		}
		
		public function getValueByIndex(index:int):uint {
			return combinations[index];
		}
		public function getIndexByValue(value:uint):int {
			return _dictValueToIndex[value]!= null ? _dictValueToIndex[value] : -1;
		}
        
        private function getArcConnectionMaskValues2():Vector.<uint> {   // 12 hardcoded arc combinations
            var vec:Vector.<uint> = new <uint>[   // setup lookup table of 6 possible connections to check
            //    0,
                (ARC_VERTICAL),
                (ARC_HORIZONTAL),
                (ARC_VERTICAL | ARC_HORIZONTAL),
                (ARC_NORTH_WEST | ARC_SOUTH_WEST),
                (ARC_NORTH_EAST | ARC_SOUTH_EAST),
                (ARC_NORTH_WEST | ARC_NORTH_EAST),   // 5 - start use 90 degree junction
                (ARC_SOUTH_WEST | ARC_SOUTH_EAST),
                (ARC_NORTH_EAST),
                (ARC_NORTH_WEST),
                (ARC_SOUTH_WEST),
                (ARC_SOUTH_EAST),   // 10 - end use 90 degree junction
                (ARC_NORTH_WEST | ARC_SOUTH_EAST),
                (ARC_SOUTH_WEST | ARC_NORTH_EAST )
            ];
            var result:uint;
            var len:int = vec.length;
            for (var i:int = 0; i < len; i++) {
                var value:uint = vec[i];
                result = 0;
                
                result |= (value & ARC_VERTICAL) ? (NORTH | SOUTH) : 0;
                result |= (value & ARC_HORIZONTAL) ? (WEST | EAST) : 0;
                result |= (value & ARC_NORTH_EAST) ? (NORTH | EAST) : 0;
                result |= (value & ARC_NORTH_WEST) ? (NORTH | WEST) : 0;
                result |= (value & ARC_SOUTH_WEST) ? (SOUTH | WEST) : 0;
                result |= (value & ARC_SOUTH_EAST) ? (SOUTH | EAST) : 0;
                
                arcEdgeDict[value] = result;
            }
            
            

            //throw new Error(vec);
            return vec;
        }
		
		private static var INSTANCE:SaboteurPathUtil;
		public static function getInstance():SaboteurPathUtil {
			return INSTANCE || (INSTANCE = new SaboteurPathUtil());
		}
		
		public function SaboteurPathUtil() {
			
			collectNumCombinations(); 
		}
        
        private function collectNumCombinations():void 
        {
            var dict:Dictionary = new Dictionary();
			_dictValueToIndex = dict;
            var vec:Vector.<uint> = getArcConnectionMaskValues2();
            
        
            var key:uint;
            var count:uint = 0;
            
            for (var i:uint = 1; i < 16; i++) {   // go through activatable east,north,west,south edge states
                for (var a:uint = 0; a < vec.length; a++) {   // go through all activable arc combinations
                    var arcValue:uint = vec[a];
                    var mask:uint = arcEdgeDict[arcValue];
                    if ( (i  & mask) != 0 && (i & mask) === mask ) {  // case with valid connectable arc combination
                    
                        key =  (arcValue << ARC_SHIFT) | i;
                        //if (key == 0) throw new Error("WRONG1");
                        if (dict[key] == null) {
                            dict[ key] = count++;
                            combinations.push(key);
                        //    arcValueList.push(arcValue);
                        }
                    }
                    
                    // case without any connecting arc
                    ///*
                    key = i;
                    //if (key == 0) throw new Error("WRONG2");
                    if (dict[key] == null) {
                        dict[ key] = count++;
                        combinations.push(key);
                    //    arcValueList.push(0);
                    }
                //    */
                }
            }
			
        }
        
        public function getArcValue(value:uint):uint {
			return (value & ARC_MASK) >> ARC_SHIFT;
		}
		
		public function isDeadEnd(value:uint):Boolean {
			return getArcValue(value) == 0;
		}
		
		public function getEdgeValue(value:uint):uint {
			return  value & ALL_SIDES;
		}
		
		public function hasCenterConnection(arcValue:uint):Boolean {
			if ((arcValue & (ARC_HORIZONTAL | ARC_VERTICAL))) return true;
			var valuer:uint = 0;
			valuer |= (arcValue & ARC_NORTH_WEST) ? (NORTH | WEST) : 0;
			valuer |= (arcValue & ARC_NORTH_EAST) ? (NORTH | EAST) : 0;
			valuer |= (arcValue & ARC_SOUTH_WEST) ? (SOUTH | WEST) : 0;
			valuer |= (arcValue & ARC_SOUTH_EAST) ? (SOUTH | EAST) : 0;
			return valuer != 15;
		}
		
	
        
        
        public function visJetty(value:uint, groupName:String):Boolean {
			
        
            var arcValue:uint = (value & ARC_MASK) >> ARC_SHIFT;
            //if (arcValue != arcValueList[index]) throw new Error("MISMATCH!:"+arcValue + ", "+arcValueList[index]);
    
            var edgeValue:uint = value & ALL_SIDES;
            var top90Deg:Boolean = arcValue === (ARC_NORTH_WEST | ARC_NORTH_EAST)  || (arcValue === (ARC_NORTH_EAST) && edgeValue===NORTH_EAST) || (arcValue === (ARC_NORTH_WEST) && edgeValue === NORTH_WEST);
            var bottom90Deg:Boolean = arcValue === (ARC_SOUTH_EAST | ARC_SOUTH_WEST)  || (arcValue === (ARC_SOUTH_EAST) && edgeValue === SOUTH_EAST) || (arcValue === (ARC_SOUTH_WEST) && edgeValue === SOUTH_WEST);
            var centerNarrow:Boolean = (arcValue === ARC_VERTICAL) && (edgeValue & (EAST | WEST)) != 0;
            
        //    /*
            switch (groupName) {
                case "side0":
               case "side0_posts":
                    return  ( value & EAST )!=0;
                case "side1":
                case "side1_posts":
                    return  ( value & NORTH )!=0; 
                case "side2":
               case "side2_posts":
                    return  ( value & WEST )!=0;
                case "side3":
                case "side3_posts":
                    return ( value & SOUTH )!=0;
                
                case "center":
                    return !centerNarrow && ((arcValue & (ARC_VERTICAL | ARC_HORIZONTAL))!=0) || top90Deg || bottom90Deg;
                case "center_top":
                     return  !centerNarrow && (arcValue & ARC_VERTICAL)!=0 || top90Deg; // has cut thru or T junction from bottom
                case "center_bottom":
                    return  !centerNarrow && (arcValue & ARC_VERTICAL)!=0 || bottom90Deg;   // has cut thru or T junction from bottom
            
                case "corner0_turn":  
                    return (arcValue & ARC_NORTH_EAST) != 0  &&  !top90Deg;  // and doesn't  have T junction from top
					
                case "corner1_turn":
                    return (arcValue & ARC_NORTH_WEST)!=0  &&  !top90Deg;
                case "corner2_turn":
                    return (arcValue & ARC_SOUTH_WEST)!=0 &&  !bottom90Deg;  // and doesn't  have T junction from bottom
                case "corner3_turn":
                    return (arcValue & ARC_SOUTH_EAST) != 0 &&  !bottom90Deg; 
                    
                case "center_narrow":
                    return centerNarrow;
        
                ///*      
                case "corner0_railing":
                    return arcValue === (ARC_VERTICAL|ARC_HORIZONTAL)  || ((arcValue & ARC_NORTH_EAST)!=0  && top90Deg);
                case "corner1_railing":
                    return arcValue === (ARC_VERTICAL|ARC_HORIZONTAL)  || ((arcValue & ARC_NORTH_WEST)!=0  && top90Deg);
                case "corner2_railing":
                    return arcValue === (ARC_VERTICAL|ARC_HORIZONTAL)  || ((arcValue & ARC_SOUTH_WEST)!=0 &&  bottom90Deg);
                case "corner3_railing":
                    return arcValue === (ARC_VERTICAL|ARC_HORIZONTAL)  || ((arcValue & ARC_SOUTH_EAST)!=0 && bottom90Deg); 
                //*/
                
                default: return true;
            }
            //    */
            ///return false;
        }

        
	
	}

}