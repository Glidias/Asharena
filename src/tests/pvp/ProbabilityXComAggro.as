package tests.pvp 
{
    import com.bit101.components.CheckBox;
    import com.bit101.components.HBox;
    import com.bit101.components.Label;
    import com.bit101.components.NumericStepper;
    import com.bit101.components.VBox;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.text.TextField;
    import flash.utils.setTimeout;
    
    /**
     * A probability calculator to deal with:
        X-Com situational hit percentages based off Enemy Aggro presence. (This is more applicable to melee combat situations).

        A way of calculating player's chance to hit/crit a target depending on surrounding attacking AI-aggroed enemies (which might include the targetted enemy as well).
        Rules are:
        1) If player prematurely dies before he can land his own strike, his strike will never hit. 
        2) If player gets hits by any AI-aggroed enemies before he can land his own strike, the player has no chance of dealing a critical hit with that strike. This is due to the fact that being hit by a blow will weaken/distract him from being able to deal an accruate/powerful strike.
        
        In the future, if there's aggro stun-based attacks, it'll also prevent player from dealing a hit.
        
        The percentage chance to hit/crit is adjusted accordingly to match the given aggro AI situation.
        
     * @author Glenn Ko
     */
    public class ProbabilityXComAggro extends Sprite
    {
        // n enemeis that woudl hit player first before player hits
        private var aggroPercChanceToHit:Vector.<Number> = new <Number>[0.25,0.5,0.75,.5,.2,.3];
        private var aggroPercChanceToCrit:Vector.<Number> = new <Number>[.5, .5, .3, .2, .5, .7];
        private var aggroDamageRanges:Vector.<int> = new <int>[25,6, 25,6, 25,6, 25,6, 25,6,  25,6];  // in percentage of average player health
        
        private var aggroProbabiltiesToKill:Vector.<Number> = new <Number>[];
        private var aggroProbabiltiesToHit:Vector.<Number> = new <Number>[];
        
        private var PLAYER_CHANCE_TO_HIT:Number = .5;
        private var PLAYER_CHANCE_TO_CRIT:Number = .5;
        private var PLAYER_HEALTH:int = 100;
		private var ENEMY_COUNTERHIT_ENABLED:Boolean = true;
        private var ENEMY_CRIT_ENABLED:Boolean = true;
        private var CRIT_DAMAGE_MULTIPLIER:Number = 3;
        
        private var _totalEnemies:int = 5;
        
        
        //private var totalNum
        
        private var field:TextField;
        
        public function ProbabilityXComAggro() 
        {
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
            
            field  = new TextField();
            field.multiline = true;
            field.autoSize = "left";
            
            addChild(field);
            
    
            calcAndDisplay();
            
            addChild(guiContainer);
            guiContainer.y = 200;
            
            setTimeout(setupAll, 400);
            
        }
        
        private function setupAll():void {
            setupGUI();
            updateGUI();
        }
        
        private function updateGUI():void 
        {
            var hBox:HBox = new HBox();
            hBox.height = 180;
            gui_hp.value = PLAYER_HEALTH;
            gui_gotEnemyCrit.selected = ENEMY_CRIT_ENABLED;
            
            gui_pcrit.value = PLAYER_CHANCE_TO_CRIT;
            gui_phit.value = PLAYER_CHANCE_TO_HIT;
                
            var stepper:NumericStepper;
            enemyVBox.removeChildren();
            for (var i:int = 0; i < _totalEnemies; i++) {
                createEnemyAt(i);
            }
            enemyVBox.draw();
            
        }
        
        private function createEnemyAt(i:int):void {
            var hBox:HBox = new HBox(enemyVBox);
            hBox.name = String(i);
            hBox.height = 15;
            var stepper:NumericStepper;
            stepper = new NumericStepper(hBox,0,0,onEnemyPercHitChanged);
            setPercStepper(stepper);
            stepper.value = aggroPercChanceToHit[i];
            stepper = new NumericStepper(hBox,0,0,onEnemyPercCritChanged);
            setPercStepper(stepper);
            stepper.value = aggroPercChanceToCrit[i];
            stepper = new NumericStepper(hBox,0,0,onEnemyMinDamageChanged);
            stepper.minimum = 0;
            stepper.maximum = 1000;
            stepper.step = 1;
            stepper.value = aggroDamageRanges[(i<<1)];
            stepper = new NumericStepper(hBox,0,0,onEnemyDamageAddChanged);
            stepper.minimum = 0;
            stepper.maximum = 1000;
            stepper.step = 1;
            stepper.value = aggroDamageRanges[(i<<1)+1];
        }
        
        private function onEnemyPercHitChanged(e:Event):void 
        {
            var index:int = int( e.currentTarget.parent.name);
            aggroPercChanceToHit[index] = e.currentTarget.value;
            calcAndDisplay();
        }
        
        private function onEnemyPercCritChanged(e:Event):void 
        {
            var index:int = int( e.currentTarget.parent.name);
                aggroPercChanceToCrit[index] = e.currentTarget.value;
                calcAndDisplay();
        }
        
        private function onEnemyMinDamageChanged(e:Event):void 
        {
            var index:int = int( e.currentTarget.parent.name);
                aggroDamageRanges[index * 2] = e.currentTarget.value;
                calcAndDisplay();
        }
        
        private function onEnemyDamageAddChanged(e:Event):void 
        {
            var index:int = int( e.currentTarget.parent.name);
            aggroDamageRanges[index * 2 + 1] = e.currentTarget.value;
            calcAndDisplay();
        }
        
        private var guiContainer:VBox = new VBox();
        private var enemyVBox:VBox;
        
        private var gui_hp:NumericStepper;
        private var gui_phit:NumericStepper;
        private var gui_pcrit:NumericStepper;
        private var gui_gotEnemyCrit:CheckBox;
        
        private function setupGUI():void {
            var stepper:NumericStepper;
            
            var hBox:HBox;
            
            hBox = new HBox(guiContainer);
            hBox.height  = 15;
            new Label(hBox, 0,0,"Player Health Left:");
            gui_hp = new NumericStepper(hBox, 0,0,onPlayerHPChanged);
            gui_hp.minimum = 0;
            gui_hp.maximum = 800;
            gui_hp.step = 1;
            hBox = new HBox(guiContainer);
            hBox.height  = 15;
            new Label(hBox, 0,0,"Player Base Chance To Hit:");
            gui_phit = new NumericStepper(hBox, 0,0, onPlayerChanceHitChanged);
            hBox = new HBox(guiContainer);
            hBox.height  = 15;
            new Label(hBox, 0,0,"Player Base Chance To Crit:");
            gui_pcrit = new NumericStepper(hBox, 0,0, onPlayerChanceCritChanged);
            
            hBox = new HBox(guiContainer);
            hBox.height  = 15;
            new Label(hBox, 0, 0, "No. of Enemies:");
            stepper = new NumericStepper(hBox, 0, 0, onTotalEnemiesChange);
            stepper.value = _totalEnemies;
            stepper.minimum = 0;
            stepper.maximum = 32;
            stepper.step = 1;
			gui_gotEnemyCrit = new CheckBox(guiContainer, 0, 0, "Enemies deal counterattacks.", onEnemyDealChanged);
			gui_gotEnemyCrit.selected = ENEMY_COUNTERHIT_ENABLED;
            gui_gotEnemyCrit = new CheckBox(guiContainer, 0, 0, "Enemies can deal critical damage.", onEnemyCritEnabledChange);
            gui_gotEnemyCrit.selected = ENEMY_CRIT_ENABLED;
            new Label(guiContainer, 0, 0, "(Chance To Hit | Chance To Crit | Min Damage | Additional Damage)");
            enemyVBox = new VBox(guiContainer);
            
            
            setPercStepper(gui_pcrit);
            setPercStepper(gui_phit);
            
            guiContainer.draw();
        }
		
		private function onEnemyDealChanged(e:Event):void 
		{
			 ENEMY_COUNTERHIT_ENABLED = e.currentTarget.selected;
            calcAndDisplay();
		}
        
        private function onEnemyCritEnabledChange(e:Event):void 
        {
            ENEMY_CRIT_ENABLED = e.currentTarget.selected;
            calcAndDisplay();
        }
        
        private function onPlayerHPChanged(e:Event):void 
        {
            PLAYER_HEALTH = e.currentTarget.value;
            calcAndDisplay();
            
        }
        
        private function onPlayerChanceHitChanged(e:Event):void 
        {
            PLAYER_CHANCE_TO_HIT = e.currentTarget.value;
            calcAndDisplay();
        }
        
            private function onPlayerChanceCritChanged(e:Event):void 
        {
            PLAYER_CHANCE_TO_CRIT = e.currentTarget.value;
            calcAndDisplay();
        }
        
        private function onTotalEnemiesChange(e:Event):void 
        {
            var lastTotalEnemies:int = _totalEnemies;
            _totalEnemies = e.currentTarget.value;
            aggroPercChanceToHit.length = _totalEnemies;
            aggroPercChanceToCrit.length = _totalEnemies;
            aggroDamageRanges.length = _totalEnemies * 2;
            
            for (var i:int = lastTotalEnemies; i < _totalEnemies; i++) {
                aggroPercChanceToHit[i] = .5;
                aggroPercChanceToCrit[i] = .5;
                aggroDamageRanges[i * 2] = 25;
                aggroDamageRanges[i * 2+1] = 6;
            }
            updateGUI();
            calcAndDisplay();
        }
        
        private function setPercStepper(gi:NumericStepper):void 
        {
            gi.minimum = 0;
            gi.maximum = 1;
            gi.labelPrecision = 2;
            gi.step = .1;
        }
        
        public function calcAndDisplay():void 
        {
            field.text = "";
            field.appendText("TOTAL ENEMIES: " + _totalEnemies + "\n");
            field.appendText("\n");
            /*
             * Chance to hit
                    For all striking aggro entities that surround a player that will hit player first before the player can land his own hit, determine the probability of such all such earlier aggro attacks prematurely killing the player before the player can land his own strike. 
                What is the percentage chance of a player hitting as a result, given circumstnaces of being aggroed and the possiblity of being prematurely killed before he can  hit his target? Note that each aggro unit can deal critical hits to the player as well besides regular hits. 

                1) Run through all possible situational sets of aggro entities (dealing either critical/non-critical hits) against the player
                2) For each sitautional set, get the probability of all such entities being able to kill the player using:
                P( Min/Max Damange inflicted among all entities >= Target's Health ) * P( All entities landing a hit on the player);
                3) For all situational sets of aggro entities that have >0 probability of killing the player prematurely, calculate the probability of either one of them occuring using the standard union formula of any one of these independant events occuring. Get the complement of this result for "probabilityOfSurviving".
                Thus, in order to hit, the player must survive as well.
                So, total chance for player to hit is: probabilityOfSurviving * playerChanceToHitTarget
            */
            field.appendText("CHANCE TO HIT: "+ Math.round( PLAYER_CHANCE_TO_HIT * getChanceToSurvive(true) * 100 ) + "%\n");
            field.appendText("Player base hit chance: " + PLAYER_CHANCE_TO_HIT  +"\n");
            field.appendText("Player's health: " + PLAYER_HEALTH +"%"  +"\n");
            field.appendText("Player's chance of survival: " + getChanceToSurvive()  +"\n");
            field.appendText("Player's aggregate: " + (PLAYER_CHANCE_TO_HIT * getChanceToSurvive(true))  +"\n");
            
            field.appendText("\n");
            /*
             * Chance to crit
            Calculate the probability of any one of these enemies being able to hit the player.
            Get the complement of this result for "probabilityOfNotGettingHit"
            So, total chance for player to crit is: probabilityOfNotGettingHit * playerChanceToHitTarget 
            */
            field.appendText("CHANCE TO CRIT (if got hit): "+ Math.round( PLAYER_CHANCE_TO_CRIT * getChanceToNotGetHit(true) * 100 ) + "%\n");
            field.appendText("Player base crit chance: " + PLAYER_CHANCE_TO_CRIT  +"\n");
            field.appendText("Player's chance to avoid getting hit: " + getChanceToNotGetHit()  +"\n");
            field.appendText("Player's aggregate: " + (PLAYER_CHANCE_TO_CRIT * getChanceToNotGetHit(true))  +"\n");
        
        }
        
        private function getChanceToNotGetHit(flag:Boolean=false):Number 
        {
            if (_totalEnemies <= 0 || (flag && !ENEMY_COUNTERHIT_ENABLED) ) {
                return 1;
            }
            return 1 - getUnionProbabilityExclusive(aggroPercChanceToHit, _totalEnemies);
        }
        
        private function accumulateAggroChanceToKill(totalCombCount:int, multiplier:Number, probabilityHitChart:Vector.<Number>):int {
            var i:uint;
            var h:uint;
            // up to 32 enemies supported for hit/miss cases
            var totalCombinations:uint = (1 << _totalEnemies);
            for (i = 1; i < totalCombinations; i++ ) {
                var accumMinDmg:int = 0;
                var accumMaxDmg:int = 0;
                var hitCount:int = 0;
                for (h = 0; h < _totalEnemies; h++) {
                    var didHit:uint = ((i >> h) & 1);
                    if (didHit != 0) {  // go through all significant bits for hits
                        accumMinDmg += aggroDamageRanges[(h<<1)] * multiplier;
                        accumMaxDmg += aggroDamageRanges[(h << 1)] + aggroDamageRanges[(h << 1) + 1] * multiplier;
                        aggroProbabiltiesToHit[hitCount++] = probabilityHitChart[h] * (multiplier == 1 ? 1 : aggroPercChanceToHit[h] );    
                    }
                }
            
                var probResult:Number = getChanceOfRangeMeetingValue(accumMinDmg, accumMaxDmg, PLAYER_HEALTH);
                if (hitCount > 0 && probResult > 0) {
                    var percChanceForAllToHit:Number = 1;
                    for (h = 0; h < hitCount; h++) {
                        percChanceForAllToHit *= aggroProbabiltiesToHit[h];
                    }
                    probResult *= percChanceForAllToHit;
                    if (probResult > 0) {
                        aggroProbabiltiesToKill[totalCombCount++] = probResult;    
                        
                    }
                }
            }
            
            return totalCombCount;
        }
        
        private function getChanceToSurvive(flag:Boolean=false):Number 
        {
            if (_totalEnemies <= 0 || (flag && !ENEMY_COUNTERHIT_ENABLED) ) {
                return 1;
            }
        
            var count:int = accumulateAggroChanceToKill(0, 1, aggroPercChanceToHit);
            if (ENEMY_CRIT_ENABLED) count = accumulateAggroChanceToKill(count, CRIT_DAMAGE_MULTIPLIER, aggroPercChanceToCrit);
            return count > 0 ? 1-getUnionProbabilityExclusive(aggroProbabiltiesToKill, count) : 1;
        }
        
        public static  function getUnionProbabilityExclusive(vec:Vector.<Number>, len:int = 0):Number {
            if (len == 0) len  = vec.length;
            var remainingProb:Number = 1;
            var result:Number = 0;
            var accum:Number = 0;
            for (var i:int = 0; i < len; i++ ) {
                result = vec[i] * remainingProb;
                remainingProb -= result;
                accum += result;
            }
            return accum;
        }
        
        public static function getChanceOfRangeMeetingValue(min:Number, max:Number, healthValue:Number):Number {
            if (healthValue <= min) return 1;
            else if (healthValue > max) return 0;
            else if (healthValue == max) return (1 / (max > min ? max - min : 1));
            else {
                return 1 - (healthValue-min) * (max - min);
            }
            //calculateOptimalRangeFactor(min, max, value); // value must lie 
        }
        
        public static  function calculateOptimalRangeFactor(minRange:Number, maxRange:Number, sampleRange:Number):Number {  // the nearer to maxRange ,the higher the ratio
        // find t 
        // sampleRange =  a + (b - a) * t;   // LERP
        //  sampleRange = (b - a) * t + a
        // sampleRange - a = (b - a) * t
        // (sampleRange - a)/ (b-a) = t;
        sampleRange = (sampleRange - minRange) / (maxRange - minRange);
        sampleRange = sampleRange < 0 ? 0 : sampleRange > 1 ? 1 : sampleRange;
        return sampleRange;
    }
        
        public function get totalEnemies():int 
        {
            return _totalEnemies;
        }
        
        public function set totalEnemies(value:int):void 
        {
            _totalEnemies = value;
        }
        
    }

}