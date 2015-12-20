// forked from shohei909's ダンジョンRPG作る step5-(コードの整理)
// forked from shohei909's 本気でダンジョンRPG作る step4-(主人公のモーションを作る)
// forked from shohei909's 本気でダンジョンRPG作る step3-(マップを立体化する)
/*
wonderflでがんばってダンジョンRPGを作ってます。


久々の更新。    
タイトルから、本気が消えたことは内緒。

今回の目標は、停滞の原因になったスパゲッティなコードを整理することです。
とゆうことでヴィジュアル的な変化は少ないと思います。
でも、敵１体くらいの絵は追加するつもりです。


さて、コードの整理の方針ですが、
今までのコードをほとんど撤廃して、

こちらのコードを流用します。
http://wonderfl.net/c/cI8m
パズルゲーム用に作ったコードですが、
こちらにもつかえそうなので、
これをつかって停滞している現状を打開したいと思ってます。

step1,2,3,4　でやってきたことが無駄になるとか気にしない！！



操作方法

移動:方向キー
攻撃: Z
びっくり: Y
階段を下りる: 階段上でSpace


マップ
    緑:部屋　または　通路
    青:敵
    ピンク:主人公
    赤:階段
通ったことのない場所の階段,敵は見えません



English

 I make a RPG.
 
 step2:  move charactors
 walk: arrow keys
 attack: Z
 go down stairs: Space

 map
    green: room or passage
    red: Enemy
    pink: player
    light blue: staire


制作過程を残していきたいのでforkを重ねて制作しています。

PREVIOUS　http://wonderfl.net/c/oDmN
NEXT　http://wonderfl.net/c/wyIu

前のステップの差分は,上の[diff()]をクリックするとみることができます
*/
package wonderfl {
    import flash.display.Sprite;
    import flash.display.Loader;
    import net.kawa.tween.KTween;
    import net.hires.debug.Stats;
    [SWF(backgroundColor="0", frameRate="60")]
    public class Game extends Sprite {
        private var loaders:Vector.<Loader>;
        private var data:Data;
		private var uiTros:UITros;
        public var dungeon:Dungeon;
        static public var effect:EffectMap;
        function Game() { 
            data = new Data();
            loaders = data.load();
            var nowload:NowLoading = new NowLoading(stage,init);
            for each(var loader:Loader in loaders){  nowload.addLoader(loader); }
        }
        private function init():void{
            stage.frameRate = 60;
            stage.quality = "low";
            stage.align = "topLeft";
            
            KTween.to(stage.getChildAt(1),3,{alpha:0},null,function():void{stage.removeChildAt(1)});
            effect = new EffectMap( 465,465 );
            dungeon = new Dungeon( data );
            addChild( dungeon );
            addChild( dungeon.mapBitmap );
            addChild( effect );
			
			initUI();
		

           // addChild( new Stats() ).alpha = 0.8
        }
		
		private function initUI():void 
		{
			addChild( uiTros=new UITros() );
				dungeon.initUI(uiTros);
		}
    }
}
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import com.bit101.components.RadioButton;
import com.bit101.components.TextArea;
import com.bit101.components.VBox;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Dictionary;


class UITros extends Sprite {
	
	public var arrowUp:PushButton;
	public var arrowDown:PushButton;
	public var arrowLeft:PushButton;
	public var arrowRight:PushButton;
	public var btnWait:PushButton;
	
	
	private var arrowControls:Sprite;
	
	public var infoPanel:Sprite;
	public var infoExchange:Label;
	public var infoMoveStep:Label;
	public var radioAttack:RadioButton;
	public var radioDefend:RadioButton;
	
	
	public static const STR_WAIT:String = "wait";  // will always roll as defense regardless
	public static const STR_MOVE:String = "move";  // basic movement without exchange resolution
	public static const STR_ATTACK:String = "Atk";  // this will resolve the attack manuever
	public static const STR_DEFEND_TEMP:String = "def";  //  this will roll defense later on
	public static const STR_FULL_EVADE:String = "Flee";  // attempt to move into a safe square to escape 
	public static const STR_PARTIAL_EVADE:String = "DefF";  // want to retreat, but can't yet, due to attacking in last exchange
	public static const STR_AIM:String = "atk";   // you are currently aiming at the enemy prior to resolving the attack manuever
	public static const STR_TURN:String = "turn";  // turn to face given direction
	public static const STR_TARG:String = "sel";  // turn to consider target
	public static const STR_DEFEND:String = "Def";  // this will resolve the defense manuever
	public static const DELIBERATE_DEFEND_SUFFIX:String = "!";  // you  deliberate chose to roll defend. appended at the end of "def" or "Def" accordingly.
	
	public static const STR_DONE:String = "Okay";
	
	public var messageBox:TextField;
	
	// once exchange is resolved from Move 1/1, next exchange begins immediately.
	
	
	public function UITros():void {
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	
	
	public function mapUpdate(dungeon:Dungeon):void 
	{
		var directions:Array = FightState.DIRECTIONS;// [[1, 0], [ -1, 0], [0, 1], [0, -1]];  //["rlbf".indexOf(man.dir)];
		//var initiativeMask:int = 0;
		//var enemyMask:int = 0;

		var wallMask:int = 0;
		var manFight:FightState = dungeon.man.components.fight; 
		var manCharSheet:CharacterSheet = dungeon.man.components.char;
		//FightState.updateNeighborEnemyStates(dungeon.man, manFight, dungeon);
		
		var len:int = directions.length;
		var gotEnemy:Boolean = manFight.numEnemies > 0;
		for (var i:int = 0; i < len; i++) {
			var dir:Array = directions[i];
			var xi:int = dir[0];
			var yi:int = dir[1];
			xi += dungeon.man.mapX;
			yi += dungeon.man.mapY;
			if (xi >= 0 && xi < dungeon.mapWidth && yi >= 0 && yi < dungeon.mapHeight) {
				
				if (dungeon.checkState(xi, yi, "stone").length > 0) {
					wallMask |= (1 << i);  
				}
			}
			else {
				wallMask |= (1 << i);
			}
		}
		

		
		
		arrowRight.visible = rightRollHolder.visible  = !(wallMask & 1);
		arrowLeft.visible =  leftRollHolder.visible  = !(wallMask & 2);
		arrowUp.visible =  upRollHolder.visible  = !(wallMask & 4);
		arrowDown.visible =  downRollHolder.visible  = !(wallMask & 8);
		arrowRight.alpha = 1;
		arrowLeft.alpha = 1;
		arrowUp.alpha = 1;
		arrowDown.alpha = 1;
		
		var emptySquareMoveString:String = gotEnemy ?  manFight.s < 1 ? STR_MOVE : STR_FULL_EVADE : STR_MOVE;  
		var atkStateString:String;
		var defendStateString:String;
		
		arrowRight.label = STR_MOVE;
		arrowLeft.label = STR_MOVE;
		arrowUp.label = STR_MOVE;
		arrowDown.label = STR_MOVE;
		btnWait.label = STR_WAIT;
		
		infoPanel.visible = gotEnemy;
		//infoExchange.visible = gotEnemy;
		//infoMoveStep.visible = gotEnemy;
		
		var fState:FightState;
	
		
		if (manFight.flags & FightState.FLAG_ENEMY_EAST) {
			
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 0))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX : ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowRight.label = manFight.flags & FightState.FLAG_INITIATIVE_EAST  ? atkStateString : defendStateString;
			arrowRight.alpha = manFight.withinInitiativeScope(fState) ? 1 : manFight.withinRollableScope(fState) ? .5 : 0;
			
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_WEST) {
		
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 1))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowLeft.label = manFight.flags & FightState.FLAG_INITIATIVE_WEST  ? atkStateString : defendStateString;
			arrowLeft.alpha =manFight.withinInitiativeScope(fState) ? 1 : manFight.withinRollableScope(fState) ? .5 : 0;
		}
		
		
		if (manFight.flags & FightState.FLAG_ENEMY_NORTH) {
			
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 2))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowUp.label = manFight.flags & FightState.FLAG_INITIATIVE_NORTH   ? atkStateString : defendStateString;
			arrowUp.alpha =manFight.withinInitiativeScope(fState) ? 1 : manFight.withinRollableScope(fState) ? .5 : 0;
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_SOUTH) {
	
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY,3))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowDown.label = manFight.flags & FightState.FLAG_INITIATIVE_SOUTH   ? atkStateString : defendStateString;
			arrowDown.alpha = manFight.withinInitiativeScope(fState) ? 1 : manFight.withinRollableScope(fState) ? .5 : 0;
		}
		
		if (gotEnemy) {  // TODO: proper context-facing info of enemy fight info instead...later on...
			setFightInfo(manFight, manCharSheet);
		}
		
		if (manFight.s == 2) {
			btnWait.label = (manFight.attacking ? "ATK" : manFight.manuevers[0].manuever == 0 ? "FLEE" :  "DEF");
			var engagedMultiple:Boolean = manFight.numEnemies > 1;
			arrowRight.visible =   arrowRight.alpha == 0 ? (rightRollHolder.visible=false) : (engagedMultiple &&  (manFight.flags & 1) != 0);  // 
			arrowLeft.visible =   arrowLeft.alpha == 0 ? ( leftRollHolder.visible=false) :  (engagedMultiple &&  (manFight.flags & 2) !=0);  // 
			arrowUp.visible =    arrowUp.alpha == 0 ? (upRollHolder.visible=false) :   (engagedMultiple &&  (manFight.flags & 4)!=0);  //
			arrowDown.visible =    arrowDown.alpha == 0 ?  ( downRollHolder.visible=false) :  (engagedMultiple &&  (manFight.flags & 8) != 0);  //
			arrowRight.label = STR_TARG;
			arrowLeft.label = STR_TARG;
			arrowUp.label = STR_TARG;
			arrowDown.label = STR_TARG;
			
			var count:int = 0;
			count += arrowRight.visible ? 1 : 0;
			count += arrowLeft.visible ? 1 : 0;
			count += arrowUp.visible ? 1 : 0;
			count += arrowDown.visible ? 1 : 0;
			if (count == 1 ) {  // only 1 selectable target, so hide all arrows..
				arrowRight.visible = false;
				arrowLeft.visible = false;
				arrowUp.visible = false;
				arrowDown.visible = false;
			}
			
		}
		else if (manFight.s == 1) {
			var evadeStr:String = manFight.lastAttacking ? STR_PARTIAL_EVADE : STR_FULL_EVADE;
			if (arrowRight.visible && arrowRight.label === STR_MOVE) {
				arrowRight.label = evadeStr;
			}
			if (arrowLeft.visible && arrowLeft.label === STR_MOVE) {
				arrowLeft.label = evadeStr;
			}
			if (arrowUp.visible && arrowUp.label === STR_MOVE) {
				arrowUp.label = evadeStr;
			}
			if (arrowDown.visible && arrowDown.label === STR_MOVE) {
				arrowDown.label = evadeStr;
			}
			
		}
		
		updateRolls(dungeon, manFight);
		
	//	showDebugFights(dungeon, manFight);
		
	}
	
	private function showDebugFights(dungeon:Dungeon, manFight:FightState):void {
		var fState:FightState;
		
		if (manFight.flags & FightState.FLAG_ENEMY_EAST) {
			
				fState = FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 0);
				arrowRight.label = "e" + (fState.e ? 2 : 1) + "s" + fState.s;
	
			
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_WEST) {
		
			fState = FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 1);
			arrowLeft.label= "e" + (fState.e ? 2 : 1) + "s" + fState.s;
			
		}
		
		
		if (manFight.flags & FightState.FLAG_ENEMY_NORTH) {
			
			fState = FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 2);
			arrowUp.label= "e" + (fState.e ? 2 : 1) + "s" + fState.s;
		
		
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_SOUTH) {
	
			fState = FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 3);
			arrowDown.label = "e" + (fState.e ? 2 : 1) + "s" + fState.s;

		}
		
	}
	
	private function updateRolls(dungeon:Dungeon, manFight:FightState):void {
		upRollHolder.removeChildren();
		downRollHolder.removeChildren();
		leftRollHolder.removeChildren();
		rightRollHolder.removeChildren();
		
		if (manFight.s == 2 ) { // show roll intiatatives
			var count:int = 0;
			var eFight:FightState;
			var dir:Array =  FightState.DIRECTIONS;
			if (manFight.flags & FightState.FLAG_ENEMY_EAST) {
				eFight = dungeon.getComponent(dungeon.man.mapX + dir[0][0], dungeon.man.mapY + dir[0][1], "fight");
				showRollAt( rightRollHolder, (eFight.attacking ? "attack" : "defend"), count++);
				
			}
			
			if (manFight.flags & FightState.FLAG_ENEMY_WEST) {
				eFight = dungeon.getComponent(dungeon.man.mapX + dir[1][0], dungeon.man.mapY + dir[1][1], "fight");
				showRollAt( leftRollHolder, (eFight.attacking ? "attack" : "defend"), count++);
				
			}
			
			
			if (manFight.flags & FightState.FLAG_ENEMY_NORTH) {
				eFight = dungeon.getComponent(dungeon.man.mapX + dir[2][0], dungeon.man.mapY + dir[2][1], "fight");
			
				showRollAt( upRollHolder, (eFight.attacking ? "attack" : "defend"), count++);
				
				
			}
			
			if (manFight.flags & FightState.FLAG_ENEMY_SOUTH) {
				eFight = dungeon.getComponent(dungeon.man.mapX + dir[3][0], dungeon.man.mapY + dir[3][1], "fight");
				showRollAt( downRollHolder, (eFight.attacking ? "attack" : "defend"), count++);
				
				
			}
			
		}
	}
	
	private function sizeBtn(btn:PushButton, width:Number = 30, height:Number = 20 ):PushButton {
		btn.width = width;
		btn.height = height;
		return btn;
	}
	
	private var upRollHolder:Sprite = new Sprite();
	private var downRollHolder:Sprite = new Sprite();
	private var leftRollHolder:Sprite = new Sprite();
	private var rightRollHolder:Sprite = new Sprite();
	private var rollIconWidth:Number = 8;
	private var DEFEND_ICON_CACHE:Array = [];
	private var ATTACK_ICON_CACHE:Array = [];
	
	private function getIconSquare(color:uint):Shape {
		var shape:Shape = new Shape();
		
		shape.graphics.beginFill(color, 1);
		//shape.graphics.drawRect(0, -rollIconWidth*.5, rollIconWidth, rollIconWidth );
		shape.graphics.drawCircle(0, 0, 4);
		
		return shape;
	}
	
	
	public function showRollAt(contDirection:Sprite, roll:String, count:int):void {
		var rot:Number;
		if (contDirection === downRollHolder) {
			rot = Math.PI * .5;
		}
		else if (contDirection === leftRollHolder) {
			rot = Math.PI * .5*2;
		}
		else if (contDirection === upRollHolder) {
			rot = Math.PI * .5*3;
		}
		else {
			rot = 0;
		}
	
		var cacheArr:Array;
		switch( roll) {
			case "defend": cacheArr = DEFEND_ICON_CACHE; break;
			case "attack": cacheArr = ATTACK_ICON_CACHE;  break;
			default:return;
		}
		
		var disp:DisplayObject = cacheArr[count];
		disp.rotation = rot;
		contDirection.addChild( disp );
	
	}
	
	private function onAddedToStage(e:Event):void 
	{
		arrowControls = new Sprite();
		infoPanel = new VBox();
		
		arrowControls.addChild(upRollHolder);
		arrowControls.addChild(downRollHolder);
		arrowControls.addChild(leftRollHolder);
		arrowControls.addChild(rightRollHolder);
		var i:int;
		
		for (i = 0; i < 4; i++)  DEFEND_ICON_CACHE.push( getIconSquare(0xFFFFFF) );
		for (i = 0; i < 4; i++) ATTACK_ICON_CACHE.push( getIconSquare(0xFF0000) );
		
		
		infoPanel.x = 2;
		infoPanel.y = 2;
		addChild(arrowControls);
		addChild(infoPanel);
		
		arrowControls.x = stage.stageWidth - 75;
		arrowControls.y = stage.stageHeight - 60;
		arrowUp = sizeBtn( new PushButton(arrowControls, 0, -25, STR_MOVE) );
		arrowDown = sizeBtn( new PushButton(arrowControls, 0, 25, STR_MOVE) );
		arrowLeft =  sizeBtn( new PushButton(arrowControls, -35, 0, STR_MOVE) );
		arrowRight =  sizeBtn( new PushButton(arrowControls, 35, 0, STR_MOVE) );
		btnWait =  sizeBtn( new PushButton(arrowControls, 0, 0, STR_WAIT) );
		
		leftRollHolder.x = btnWait.x;
		rightRollHolder.x = btnWait.x +30;
		upRollHolder.x = btnWait.x + 30 * .5;
		downRollHolder.x = btnWait.x + 30 * .5;
		
		upRollHolder.y = btnWait.y;
		downRollHolder.y = btnWait.y + 20;
		leftRollHolder.y = btnWait.y + 20 * .5;
		rightRollHolder.y = btnWait.y + 20 * .5;
		
		
		
		infoExchange = new Label(infoPanel, 0, 0, "Exchange #1");
		infoMoveStep = new Label(infoPanel, 0, 0, "Move 0/1");
		radioAttack = new RadioButton(infoPanel, 0, 0, "Roll Attack", true, onRadioClick);
	//	radioAttack.enabled = false;
		radioDefend = new RadioButton(infoPanel, 0, 0, "Roll Defense", false, onRadioClick);
	
		messageBox = new TextField();
		messageBox.multiline = true;
		messageBox.wordWrap = true;
		messageBox.width = stage.stageWidth * .65;
		messageBox.height = 166;
		messageBox.x = 5;
		messageBox.y = stage.stageHeight - 166 - 5;
		messageBox.textColor = 0xFFFFFF;
		
		//messageBox.blendMode = "invert";
		addChild(messageBox);

		//	messageBox.setTextFormat( messageBox.defaultTextFormat = new TextFormat("PF Ronda") );
			//messageBox.embedFonts = true;
		
	
		
		
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		TRACE = addMessageLine;
		CLEAR_TRACE = clearMessages;
	}
	
	private function clearMessages():void {
		messageBox.text = "";
		//messageBox.scrollV = 99999999;
	}
	
	public static var TRACE:Function;
	public static var CLEAR_TRACE:Function;
	
	public function addMessageLine(text:String):void {
		messageBox.appendText(text + "\n");
		messageBox.scrollV = 99999999;
	}
	
	private function onRadioClick(e:Event):void 
	{
		radioDefend.label = radioDefend.selected ? "Roll Defense!" : "Roll Defense";
	}
	
	public static const ROLLING_TEXT:String = "Rolling..";
	
	public function setFightInfo(fight:FightState, charSheet:CharacterSheet):void {
		infoExchange.text = "Exchange #" + (fight.e ? "2" : "1") + " (Round " + (fight.rounds + 1) + "),  CP: " +fight.combatPool + "/" + charSheet.getMeleeCombatPoolAmount() + "(-"+charSheet.cpDepletion+")";
		//+"Last attacking?:"+fight.lastAttacking
		infoMoveStep.text =  fight.s < 2 ? "Move " + fight.s + "/1" : "Rolling "+(fight.attacking ? "Attack" : "Defense")+"...";
		radioAttack.enabled = fight.initiative;
		radioAttack.visible = fight.s < 2;
		radioDefend.visible = fight.s < 2;
	}
	
}


import flash.system.LoaderContext;
import flash.geom.*;
import flash.display.*;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import net.kawa.tween.KTween;

import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.view.BasicView;
import org.papervision3d.cameras.CameraType;  
import org.papervision3d.scenes.Scene3D;

import wonderfl.Game;


//オブジェクト作成はデータのロード後に行う。
class Dungeon extends Sprite{
    //イメージの場所を記録した配列
    private var imgArray:Array;
    public var mapWidth:uint,mapHeight:uint;

    public var map:Vector.<Vector.<Array>> = new Vector.<Vector.<Array>>(); //gameObjectを格納
    public var mapBitmap:Bitmap = new Bitmap();    
    public var rooms:Vector.<Rectangle> = new Vector.<Rectangle>;
    public var state:State = new State();
    public var data:Data;
    
    private var keyEvent:KeyboardEvent;
	public var uiTros:UITros;

    public var count:int = 0;
	public var timestamp:uint = 0;
    public var wait:int = 0; //設定されている時間だけ一時停止
    public var stop:Boolean; //trueのときだけ一時停止
    public var man:GameObject;
    
    public var view:BasicView;
	
	public var fightStack:Array = [];
	public function clearFightStack():void {  
		var fight:FightState;
	// code smell hack here
		var i:int = fightStack.length;
		
		
		i = fightStack.length;
		while ( --i > -1 ) {
			
			fight = fightStack[i];
			FightState.updateNeighborInitiative(fight, this);
		}
		
		
		
	}
    
    function Dungeon(d:Data){
        view = new BasicView(Data.gameWidth,Data.gameHeight,false,true,CameraType.FREE);
        addChild( view );
        mapBitmap.alpha=0.8;mapBitmap.x = 300; mapBitmap.y = 430; mapBitmap.scaleX = 3;mapBitmap.scaleY = -3; 
        data = d;
        
        man = new GameObject();
        down();   
        with( view.camera ){ z = -335; zoom = 70; rotationX = -35; }
        view.startRendering(); 
        addEventListener( "addedToStage",init );
    }
    private function init(e:Event):void{
        removeEventListener("addedToStage",init);
        
        addEventListener("enterFrame", onFrame );
        stage.addEventListener("keyDown", onKeyDownCheck );
        stage.addEventListener("keyUp", onKeyUp );
        
        mask = new Bitmap( new BitmapData(1,1) );
        mask.scaleX=Data.gameWidth; mask.scaleY=Data.gameHeight;
        mask.x=(stage.stageWidth*stage.scaleX-Data.gameWidth)/2; mask.y=(stage.stageHeight*stage.scaleY-Data.gameHeight)/2;
        addChild(mask);
    }
    
	///*
	private function onKeyDownCheck(e:KeyboardEvent):void {
		var kc:uint = e.keyCode;

		switch (kc) {
			case Keyboard.ENTER:
			case Keyboard.NUMPAD_ENTER:
			case Keyboard.NUMPAD_5:
			case Keyboard.P: break;
			case Keyboard.UP:
				if (!uiTros.arrowUp.visible) e.keyCode = Keyboard.P;
			break;
			case Keyboard.DOWN:
				if (!uiTros.arrowDown.visible)  e.keyCode = Keyboard.P;
			break;
			case Keyboard.LEFT:
				if (!uiTros.arrowLeft.visible)  e.keyCode = Keyboard.P;
			break;
			case Keyboard.RIGHT:
				if (!uiTros.arrowRight.visible)  e.keyCode = Keyboard.P;	
			break;
			case Keyboard.I:
				tracePlayerCharInfo();
			return;
			default:return;
		}
		onKeyDown(e);
	}
	private function getPlayerCharInfoStr():String {
		var charSheet:CharacterSheet = man.components.char;
		 return "Health:" + charSheet.getCurrentHealth() + "/" + charSheet.health + ", RoundCP:" + charSheet.getMeleeCombatPoolAmount() + ", BL:" + charSheet.getTotalBloodLost() + ", Pain:" + charSheet.getTotalPain();
	}
	private function tracePlayerCharInfo():void 
	{
		
		UITros.TRACE(getPlayerCharInfoStr() );
	}
	//*/
	
    //新しい階層を設定する
    private function initFloor(flr:int):void {
        Data.makeMap( this, flr );
        Data.stand( this );　//マップを立体化
        mapBitmap.bitmapData = MapUtil.mapBitmap( this );
        onFrame();
		
		handleTimestampUpdate();
		
		
    }
	
	private function handleTimestampUpdate():void {
		 FightState.updateSurroundingStates(this, man.mapX, man.mapY, mapWidth >= mapHeight ? mapWidth : mapHeight);
		uiTros.mapUpdate(this);
		
		
		resolveFightStack();
		
		//tracePlayerCharInfo();
	}
	
	private var manueverStack:ManueverStack = new ManueverStack();
	
	private function resolveFightStack():void 
	{
		var entList:Vector.<GameObject>;
		var primaryManuever:Object;
		var fight:FightState;
		// for declaring manuevers , details thereof, if required
		
		var i:int = fightStack.length
		var ent:GameObject;
		var charSheet:CharacterSheet;
		
		var defenderList:Array = [];
		
		i = fightStack.length;
		while (--i > -1) {
			fight = fightStack[i];
			if ( !fight.isRolling() ) {
				continue;
			}
			
			primaryManuever = fight.manuevers[0];
			entList = checkComponent(fight.x, fight.y, "fight");
			if (entList.length > 0) {
				ent = entList[0];
			}
			else {
				throw new Error("Exception fight missing at location!");
			}
			charSheet = ent.components.char;
			
			// manuever.to might be different in some cases...
			if (fight.attacking) {
				primaryManuever.from = ent;
				primaryManuever.to  = checkComponent(fight.x+ent.moveArray[0],fight.y+ent.moveArray[1], "fight")[0];
				if (primaryManuever.to == null) throw new Error("Could not find attack initiative's target");
				
				primaryManuever.reflexScore = charSheet.getReflex()* 1000 + Math.random() * 10;
				manueverStack.pushManuever( primaryManuever );
				
			}
			else {
				defenderList.push({entity:ent, reflexScore: charSheet.getReflex()* 1000 + Math.random() * 10 });
			}
			
			// tODO later
			// go through other manuevers if necessary 
			for (var k:int = 1; k < fight.manuevers.length; k++) {
				var kManuever:Object = fight.manuevers[k];  // assumed manuever is explicitly defined
				//if (kManuever.attacking) {
					
					/*
					kManuever.from = ent;
					kManuever.to  = checkComponent(fight.x+ent.moveArray[0],fight.y+ent.moveArray[1], "fight")[0];
					if (primaryManuever.to == null) throw new Error("Could not find attack initiative's target");
					
					primaryManuever.reflexScore = charSheet.getReflex()* 1000 + Math.random() * 10;
					manueverStack.pushManuever( primaryManuever );
					*/
				//}
			}
		}
		
		// Declare menuvers
		manueverStack.sortOnHighestToLowest("reflexScore");
		
		var cManuever:Object;
		var playerAtkInterfaceShown:Boolean = false;
		var playerBeingAttacked:Boolean = false;
		var targetEnt:GameObject;
		var targetCharSheet:CharacterSheet;
		var targetFight:FightState;
		var dManuever:Object;
		var arrOfAvailManuevers:Array;

		i = manueverStack.stack.length;

		
		while (--i > -1) {
			cManuever = manueverStack.stack[i];
			ent = cManuever.from;
			targetEnt = cManuever.to;
			charSheet = ent.components.char;
			fight  = ent.components.fight;
			targetCharSheet = targetEnt.components.char;
			targetFight = targetEnt.components.fight;
			
			if ( ent != man) {  // is AI
				 // get AI to decide on a specific manuever from a list of available manuevers 
				 //fight.enemyManuevers.length > 0 ? fight.enemyManuevers,
				 dManuever = fight.enemyManuevers.length > 0 ? fight.enemyManuevers[0] : null; // todo: proper pick function based on facing direction of attack
				arrOfAvailManuevers = fight.getListOfAvailableManuevers(charSheet, fight, ent, dManuever != null ?  dManuever.manuever : null, dManuever != null ? dManuever.numDice : 0, dManuever != null ? dManuever.targetZone : 0 );
			//	throw new Error(JSON.stringify(arrOfAvailManuevers));
				if (ent.func.aiChooseManuever != null) {
					ent.func.aiChooseManuever(charSheet, fight, cManuever, arrOfAvailManuevers, ent);
				}
				else {
					FightState.pickDefaultManuever(charSheet, fight, cManuever, arrOfAvailManuevers, ent);
				}
				// NOTE: if manuever is double attack or some composite, then need to find a way to split attack.into 2.
				// Also need to handle case for simulatenous block/strike ,?
				
				if (targetEnt == man) {  // player character being attacked
					playerBeingAttacked = true;
					
					// with detected manuever
					var withStr:String = "with:"+ (cManuever.manuever as Manuever).name + ", "+cManuever.numDice + " CP. tn:"+cManuever.tn;
					UITros.TRACE(!playerAtkInterfaceShown ? "Player detects " + getNameWithDirToMan(ent) + " attacking..."+withStr : "("+getNameWithDirToMan(ent) + " is attacking )")
			
				}
				else { 
					
				}
				
				
				// commit enemyManuever to fight, 
				targetFight.notifyAttack( cManuever);
				
				
			}
			else {  // from player, break and defer the rest of the declaration for the remaining AI ??? For now, just let AI attack blindly
				//Show player decision manuever interface...list of available manuevers
				
				UITros.TRACE("Player is attacking...");
				playerAtkInterfaceShown = true;
			}
	
		}
		
		if (!playerAtkInterfaceShown && playerBeingAttacked) { 
			// for informational purposes only
			// var totalEnemyAttacks:int = (man.components.fight as FightState).enemyManuevers.length;
			//UITros.TRACE("Player is defending...");
			
		}
		
		
		defenderList = defenderList.sortOn("reflexScore", Array.DESCENDING);
		// go through defender list
		i = defenderList.length;
		while (--i > -1) {
			var defender:GameObject = defenderList[i].entity;
			fight = defender.components.fight;
			if ( defender != man) {
				///*
				if (fight.enemyManuevers.length > 0) {  // defender must respond to immiment enemy attack in his facing direction, 
					// if he lacks facing direction, then he must turn to closest facing direction rnadomly, or turn behind.
					dManuever = fight.enemyManuevers[0];  // todo: proper pick function
					if (fight.manuevers[0].manuever == 0) {}    // TODO: full evasion case, should pick FUll Evasion by default...just need to spend approipiate CP
					
					
					fight.getListOfAvailableManuevers(charSheet, fight, ent, dManuever.manuever, dManuever.numDice, dManuever.targetZone   );
					
					cManuever = { };
					if (ent.func.aiChooseManuever != null) {
						ent.func.aiChooseManuever(charSheet, fight, cManuever, arrOfAvailManuevers, ent);
					}
					else {
						FightState.pickDefaultManuever(charSheet, fight, cManuever, arrOfAvailManuevers, ent);
					}
					// later: ability to defend against multiple attacks via 1 left hand/1 right hand/ and as many partial evasions
					dManuever.defManuever = cManuever;
					UITros.TRACE( "Defending with:"+ (cManuever.manuever as Manuever).name + ", "+cManuever.numDice + " CP. tn:"+cManuever.tn);
					
					// later : if defensive manuever is Full Evade, need to check it in wth direction .
				
				}
				else {
					// LATER:
					// defender might still want to force-enter initiative, or attempt to defend just in case, if he is adjacient to a potential enemy that hasn't declared his move yet.
				}
				
			}
			else {
				 // show player decision defending manuever interface...list of available manuevers
				var totalEnemyAttacks:int = (man.components.fight as FightState).enemyManuevers.length;
				UITros.TRACE("Player is defending...");
			}
			
		}

		
		
		fightStack.length = 0;
	}
	
	
	
	private function reorderManueverStackForResolution():void {  
		// LATER: double attack manuevers from the same person need to share the same reflex score value?
		var i:int = manueverStack.stack.length;
		var cManuever:Object;
		var charSheet:CharacterSheet;
		// assign a
		while (--i > -1) {
			cManuever = manueverStack.stack[i];
			charSheet = cManuever.from.components.char;
			cManuever.reflexScore = Manuever.getRollNumSuccesses(charSheet.getReflex(), cManuever.tn ); 
		}
		manueverStack.sortOnLowestToHighest("reflexScore");
	}
	
	private function resolveManueverStack():void {
		var ent:GameObject;
		var targetEnt:GameObject;
		var tarCharSheet:CharacterSheet;
		var charSheet:CharacterSheet;
		
		var cManuever:Object;
		
	
		var i:int = manueverStack.stack.length;
		while (--i > -1) {
			cManuever = manueverStack.stack[i];
			ent = cManuever.from;
			targetEnt = cManuever.to;
			charSheet = ent.components.char;
			tarCharSheet = targetEnt.components.char;
			UITros.TRACE(getNameWithDirToMan(ent) + " resolved attack against " + getNameWithDirToMan(targetEnt));
		}

	}
	
	public function getNameWithDirToMan(ent:GameObject):String {
		return (man.x!=ent.x || man.y != ent.y) ? ent.components.char.name + "("+(man.x != ent.x ? ent.x < man.x ?  "W" : "E"  :  ent.y < man.y ? "S" : "N"  )+")" : ent.components.char.name;
	}
	
    //ダンジョンを下る
    public function down():void{ 
        state.floor--; stop = true; Game.effect.moving = true;
        KTween.to( Game.effect.color,1,{a:1},null,function f1():void{
                stop = false; 
                initFloor( state.floor );
                KTween.to( Game.effect.color,1,{a:0},null,function f2():void{ Game.effect.moving = false } );
        })
    }
    //位置を指定して、その位置の状態を確かめる
	
	
	// temporary for now until code refactor
	private  var EMPTY_VEC:Vector.<GameObject> = new Vector.<GameObject>();
	private  var SAMPLE_VEC:Vector.<GameObject> = new Vector.<GameObject>();
	
    public function check(x:int,y:int,type:String = ""):Vector.<GameObject>{
        var vec:Vector.<GameObject> = EMPTY_VEC;
		SAMPLE_VEC.length = 0; 
        for each( var obj:GameObject in map[x][y] ) { if ( (obj.ability[type] != null ) || type == "" ) { vec = SAMPLE_VEC; vec.push(obj) } } 
        return vec;
    }
	
	public function containsObjAt(x:int, y:int, gobj:GameObject):Boolean {
		  for each( var obj:GameObject in map[x][y] ) { if (gobj === obj) return true;  } 
        return false;
	}
	
	public function checkBumpable(x:int, y:int):Boolean {
		
        for each( var obj:GameObject in map[x][y] ) { if ( (obj.func["key"] != null )) return true;  } 
        return false;
	}
	 
	public function checkFunc(x:int,y:int,type:String = ""):Vector.<GameObject>{
        var vec:Vector.<GameObject> = EMPTY_VEC;
		SAMPLE_VEC.length = 0; 
        for each( var obj:GameObject in map[x][y] ) { if ( (obj.func[type] != null ) || type == "" ) { vec = SAMPLE_VEC; vec.push(obj) } } 
        return vec;
    }
	
	 public function checkComponent(x:int,y:int,type:String = ""):Vector.<GameObject>{
        var vec:Vector.<GameObject> = EMPTY_VEC;
		SAMPLE_VEC.length = 0; 
        for each( var obj:GameObject in map[x][y] ) { if ( (obj.components[type] != null ) || type == "" ) { vec = SAMPLE_VEC; vec.push(obj) } } 
        return vec;
    }
	
	public function getComponent(x:int,y:int,type:String):* {
    
        for each( var obj:GameObject in map[x][y] ) { if ( (obj.components[type] != null ) || type == "" ) { return obj.components[type]; } } 
        return null;
    }
	
	
    //位置を指定して、その位置の状態を確かめる
    public function checkName(x:int, y:int, name:String = ""):Vector.<GameObject> {
		 var vec:Vector.<GameObject> = EMPTY_VEC;
		SAMPLE_VEC.length = 0; 
  
        for each( var obj:GameObject in map[x][y] ){ if( obj.name == name || name == "" ){ vec = SAMPLE_VEC;vec.push(obj) } } 
        return vec;
    }
	
	 public function checkState(x:int, y:int, state:String = ""):Vector.<GameObject> {
		 var vec:Vector.<GameObject> = EMPTY_VEC;
		SAMPLE_VEC.length = 0; 
        
        for each( var obj:GameObject in map[x][y] ){ if( obj.state == state || state == "" ){ vec = SAMPLE_VEC;vec.push(obj) } } 
        return vec;
    }
	
	/*
	 public function checkType(x:int,y:int,type:String = ""):Vector.<GameObject>{
        var vec:Vector.<GameObject> = new Vector.<GameObject>()
        for each( var obj:GameObject in map[x][y] ){ if( (obj.type ===  type ) ) { vec.push(obj) } } 
        return vec;
    }
	*/
	
	    public function initUI(uiTros:UITros):void 
    {
        this.uiTros = uiTros;
        uiTros.btnWait.addEventListener(MouseEvent.CLICK, doWait);
		uiTros.arrowLeft.mouseChildren = false;
		uiTros.arrowUp.mouseChildren = false;
		uiTros.arrowRight.mouseChildren = false;
		uiTros.arrowDown.mouseChildren = false;
		
        uiTros.arrowLeft.addEventListener(MouseEvent.MOUSE_DOWN, onArrowDown);
        uiTros.arrowUp.addEventListener(MouseEvent.MOUSE_DOWN, onArrowDown);
        uiTros.arrowDown.addEventListener(MouseEvent.MOUSE_DOWN, onArrowDown);
        uiTros.arrowRight.addEventListener(MouseEvent.MOUSE_DOWN, onArrowDown);
		
		
		 uiTros.arrowLeft.addEventListener(MouseEvent.ROLL_OUT, onArrowRollOut);
        uiTros.arrowUp.addEventListener(MouseEvent.ROLL_OUT, onArrowRollOut);
        uiTros.arrowDown.addEventListener(MouseEvent.ROLL_OUT, onArrowRollOut);
        uiTros.arrowRight.addEventListener(MouseEvent.ROLL_OUT, onArrowRollOut);
		/*
		 uiTros.arrowLeft.addEventListener(MouseEvent.ROLL_OVER, onArrowRollOver);
        uiTros.arrowUp.addEventListener(MouseEvent.ROLL_OVER, onArrowRollOver);
        uiTros.arrowDown.addEventListener(MouseEvent.ROLL_OVER, onArrowRollOver);
        uiTros.arrowRight.addEventListener(MouseEvent.ROLL_OVER, onArrowRollOver);
		*/
        
		uiTros.radioAttack.addEventListener(MouseEvent.CLICK, onRadioInitiativeChange, false,-1);
        uiTros.radioDefend.addEventListener(MouseEvent.CLICK, onRadioInitiativeChange, false ,-1);
        //uiTros.arrowLeft.addEventListener(MouseEvent.MOUSE_UP, onArrowUp);
       // uiTros.arrowUp.addEventListener(MouseEvent.MOUSE_UP, onArrowUp);
       // uiTros.arrowDown.addEventListener(MouseEvent.MOUSE_UP, onArrowUp);
       // uiTros.arrowRight.addEventListener(MouseEvent.MOUSE_UP, onArrowUp);
    }
	
	private function onArrowRollOut(e:MouseEvent):void 
	{
		 onArrowUp(null);
	}
	
	private function onArrowRollOver(e:MouseEvent):void 
	{
		// onArrowUp(null)
	}
	
	
	private function onRadioInitiativeChange(e:Event):void 
	{
		uiTros.mapUpdate(this);
	}
    
    private function onArrowDown(e:MouseEvent):void 
    {
        var targ:Object = e.currentTarget;
        handleArrowDown(targ);
		stage.addEventListener(MouseEvent.MOUSE_UP, onArrowUp);
		stage.addEventListener(Event.MOUSE_LEAVE, onArrowUp);
    }
    
    private function onArrowUp(e:Event):void 
    {
      //  var targ:Object = e.currentTarget;
     //   handleArrowUp(targ);
		stage.removeEventListener(MouseEvent.MOUSE_UP, onArrowUp);
		stage.removeEventListener(Event.MOUSE_LEAVE, onArrowUp);
		 onKeyUp(null);
    }
	
	private function handleArrowDown(targ:Object):void 
	{
		var kb:uint;
		if (targ === uiTros.arrowLeft) {
			kb = Keyboard.LEFT;
		}
		else if (targ === uiTros.arrowRight) {
			kb = Keyboard.RIGHT;
		}
		else if (targ === uiTros.arrowDown) {
			kb = Keyboard.DOWN;
		}
		else {
			kb = Keyboard.UP;
		}
		onKeyDown( new KeyboardEvent(KeyboardEvent.KEY_DOWN, false, false, 0,kb)  );
	}
	
	private function handleArrowUp(targ:Object):void 
	{
		var kb:uint;
		if (targ === uiTros.arrowLeft) {
			kb = Keyboard.LEFT;
		}
		else if (targ === uiTros.arrowRight) {
			kb = Keyboard.RIGHT;
		}
		else if (targ === uiTros.arrowDown) {
			kb = Keyboard.DOWN;
		}
		else {
			kb = Keyboard.UP;
		}
		onKeyUp( new KeyboardEvent(KeyboardEvent.KEY_UP, false, false, 0,kb)  );
	}
	
	
	//private var keyStrokes:Dictionary = new Dictionary();
	
	private function doWait(e:MouseEvent):void 
	{
		//onFrame();
	//	onKeyDown(new KeyboardEvent.KEY_DOWN,
		//if (wait == 0)
		performKeyStroke(Keyboard.P);
	}
	
	
	public function performKeyStroke(keycode:uint):void {
		keyEvent = new KeyboardEvent(KeyboardEvent.KEY_DOWN, false, false, 0, keycode);
		addEventListener(Event.ENTER_FRAME,  onNextFrameKeyDone);
	}
	
	private function onNextFrameKeyDone(e:Event):void 
	{
		removeEventListener(Event.ENTER_FRAME, onNextFrameKeyDone);
		keyEvent = null;  // shortcut
		//	onKeyUp(curKeyStroke);
	}
    
	public static const SEE:Array = [5, 5, 5, 6];
	// main game loop
    private function onFrame(e:Event = null):void {
        if(stop){
        }else {
			 wait--;
			 var canInteract:Boolean = wait <= 0;
          //  if (wait > 0  ) { wait--;
          //  }else{
                count++;
				
				if (canInteract && keyEvent != null) {
					UITros.CLEAR_TRACE();
					reorderManueverStackForResolution();
					resolveManueverStack();
					manueverStack.reset(); // end of fight resolution
				}
				
                var see:Array = SEE;
                var startX:int = 0,startY:int = 0,endX:int = mapWidth-1,endY:int = mapHeight-1;
                for(var i:uint = startX; i<=endX; i++ ){
                    for(var j:uint = startY; j<=endY; j++ ){
                        var o:GameObject;
                        if( man.mapX-see[0] < i && i < man.mapX+see[1] && man.mapY-see[2] < j && j < man.mapY+see[3] ){
                            for each( o in map[i][j]){
                                if( o.plane.visible == false ){ o.plane.visible = true; }
                                if( o.tween != null && o.tween.length > 0){ o.move() }
                                if( (o.tween == null || o.tween.length == 0) && o.func.frame != null ){ o.func.frame(o) }
                               
                                if( o.anim != null ){ 
                                    o.animation();
                                    Data.setPlane(o);
                                    data.draw(o.bitmapData, o.type, o.num + o.dir + o.state, 0, 0 );
                                }
								
								// if bump  phase, skip this.
								
			
								if ( canInteract && keyEvent != null && (o.components && o.components.fight != null)) o.components.fight.resolve(o);
								
								// if bump phase, only go through key for post bumpers, for humans only
								 if(  canInteract  && (o.tween == null || o.tween.length == 0) && keyEvent != null && o.func.key != null ){ o.func.key(keyEvent,o); } 
                            }
                        }else{
                            for each( o in map[i][j]){
                                if(o.plane.visible){ o.plane.visible = false }
                            }
                        }
                    }
                }
				
				
			
					
				// Those that have empty squares to move into (non-bumpers), will move first.
				// todo: proper initiative ladder for move-sliding based off RPG stats
                for(i = startX; i<=endX; i++ ){for(j = startY; j<=endY; j++ ){
                        for each( o in map[i][j] ) { if (o.moving) { o.slide(); } }
                } }
				
				if (man.bumping) {
			
					// check if  bumped-into square is vacated, if so , need to defer map update till next keypress
					if (!checkBumpable(man.mapX + man.moveArray[0], man.mapY + man.moveArray[1]) ) {
						// todo: uiTros must handle map.bumping case to only show possible moves only, without updating exchange info
						// consider limited movement allowance for movers , those that have to roll, can neither bump nor move
						
						// for next keypress frame, only consider bumpers, and do this ONLY once!
					}
				}
				
				// proper initiative ladder for bump-sliding based off RPG stats
				 for(i = startX; i<=endX; i++ ){for(j = startY; j<=endY; j++ ){
                        for each( o in map[i][j] ) { if (o.bumping) {
							// note: more advanced ai should consider pre-bump-sliding decisions, if bumped-into square is vacated
							
							//o.slide();
							///*
							if (!o.slide()) {
								if (o.components.fight != null) {
									o.components.fight.bumping = true;
								}
							}
							//*/
						}
					}
                } }
				
				
				
				
                view.camera.x = man.x;
                view.camera.y = -256 + man.y;
                if (  canInteract && keyEvent != null ) {   // assumed player has interacted with the map somewhat    // count % 6 == 0
					// execute combat decisisions
					// for those moving to:
					
					
					// resolve rest of turn
					timestamp++;
                    MapUtil.mapUpdate( this ); 
                    //if ( count % 12 == 0 )  
					MapUtil.mapDraw( this );  
					
					handleTimestampUpdate();
					
					// handle 2/1 fightstates, considering existing moveArrays if available...
                }
          //  }
        }
        if( Game.effect.moving ){ Game.effect.onFrame() }
    }
    private function onKeyDown(e:KeyboardEvent):void{ keyEvent = e; }
    private function onKeyUp(e:KeyboardEvent):void{ keyEvent = null; }
}

//マップに配置するオブジェクト
class GameObject extends Object {
    public var anim:Object;                //アニメーションに関するデータ
    
	public static var DEFAULT_STEP_NUM_FRAMES:int = 5;
	public static var WAITKEY_STEP_NUM_FRAMES:int = 10;
	
	
    public var dir:String = "";        //向き
    public var num:String = "";        //番号
    public var moveArray:Array = [0,0,5];
    public var moving:Boolean = false;
	public var bumping:Boolean = false;
    
	public var components:Object = {}; // obj
    public var ability:Object = {};    //bool値を格納するための オブジェクト
    public var func:Object = {};    //functionを格納するための　オブジェクト
    public var param:Object = {};    //paramを格納するための　オブジェクト
    
    //ゲームオブジェクトの外見
    public var visual:String = "stand";    //プレートの配置方法を指定
    
    public var name:String;    //オブジェクトの名前
    public var dungeon:Dungeon;    //配置された部屋 

    public var x:int=0,y:int=0;
    public var mapX:uint=0,mapY:uint=0;
    public var state:String;    //画像の状態
    public var type:String;        //使用する画像のタイプ
    public var count:int = 0;
    public var animState:String;//現在選択されているアニメーション
    
    public var bitmapData:BitmapData;
    public var plane:Plane;
    
    //tween?
    public var tweenFrame:Vector.<int>;
    public var tween:Vector.<Object>;
	
	// (starting from right) first bit: x is non-zero,   second bit: non-zero value is positive
	public static var DIR_STRING_LOOKUP:Array = [
		//[[1, 0], [ -1, 0], [0, 1], [0, -1]]["rlbf"
		"f",  	  //0 : 00   //  y is negative 
		"l",      //1 : 01   //  x is negative 
		"b",      //2 : 10   //  y is positive 
		"r"	 	  //3 : 11   // x is positive 
	];
	public static function getDirection(x:int, y:int):String {
			var bits:int = 0;
					bits |= x != 0 ?  1 : 0;
					bits |= x != 0 ?  (x > 0 ? 2 : 0)  :  (y > 0 ? 2 : 0); 
					return DIR_STRING_LOOKUP[bits];
					
		
	}
    
    
    //アニメーション時に呼び出される
    public function animation():void{
        if(anim[animState]!=null){
            var data:Array = anim[animState];
            //配列から現在のカウントと一致するものを取り出す。
            data = data.filter(function(d:*, i:int, a:Array):Boolean{return d[0]==this.count},this);
            for each(var act:Array in data){
                switch(act[1]){
                    case "goto": count = act[2]; break;
                    case "action": animState = act[2];  count = -1; break;
                    default: state = act[1];
                }
            }
            count++;
        } 
    }
    
    
    public function action(state:String,count:int=0):void{
        animState = state; this.count = count;
    }
    public function addTween( o:Object, frame:int = 1):void{  //, delay:int = 0
        if(o.tween == null){ tweenFrame=new Vector.<int>;tween=new Vector.<Object>; }
        tween.push(o); tweenFrame.push(frame);
    };
    
    public function move():void{
        for(var str:String in tween[0]){
            this[str] = ( this[str]* (tweenFrame[0]-1) + tween[0][str] ) / tweenFrame[0];
        }
        tweenFrame[0]--;
        if( tweenFrame[0] == 0){ tween.shift(); tweenFrame.shift(); }
    }
    public function slide():Boolean{
       // if( moving ){
	   var res:Boolean;
            if ( dungeon.check( mapX + moveArray[0], mapY + moveArray[1], "block" ).length == 0 ) {
				res = true;
                dungeon.map[mapX][mapY].splice( dungeon.map[mapX][mapY].indexOf(this), 1 );
                mapX += moveArray[0]; mapY += moveArray[1]; 
                addTween( { x:x+Data.cellSize*moveArray[0], y:y+Data.cellSize*moveArray[1] }, moveArray[2]);
                dungeon.map[mapX][mapY].push(this)
            }else { addTween( { }, moveArray[2]); res = false; }
            moving = false
			bumping = false;
       // }
	   return res;
    }
}


//主人公の状態、所持アイテム、滞在階層,
class State {
    public var floor:int = 0;
    public var hp:int = 100;
    public var maxHp:int = 100;
    public var mp:int = 100;
    public var maxMp:int = 100;
    public var itemArray:Array = [];
    public var katana:String = "";
    public var dogi:String = "";
}

//主人公に関するデータ用クラス(static)
class Man{
    static public const anim:Object = {
        "stand": [[0,"s"]], 
        "kick":[ [0,"d"],[1,"k"],[5,"action","stand"] ],
        "sup":[ [0,"j"],[10,"action","stand"] ],
        "walk1":[ [0,"w1"],[3,"s"] ],
        "walk2":[ [0,"w0"],[3,"s"] ]
    }
    static public function key(e:KeyboardEvent,man:GameObject):void{
        var c:int; var dirX:int; var targets:Vector.<GameObject>; var o:GameObject
		man.dungeon.wait = GameObject.WAITKEY_STEP_NUM_FRAMES;  // enforce wait regardless
		 if (man.components.fight) man.components.fight.resetRolls();
		
        switch( Data.keyString[e.keyCode] ){
            case "→": walk(man,"r"); break;
            case "←": walk(man,"l"); break;
            case "↑": walk(man,"b"); break;
            case "↓": walk(man,"f"); break;
			
            //case "z": man.action("kick");man.addTween( {}, 6 ); break;
            //case "x": man.action("sup");man.addTween( {}, 6 ); break;
            case " ": if(man.dungeon.check(man.mapX,man.mapY,"stair").length > 0){man.dungeon.down()} break;
        }
    }
    static public function walk(man:GameObject, dir:String):void {
		
		var fight:FightState =  (man.components.fight as FightState);
		
		var lastDir:String = man.dir;
		
        if ( true || dir == man.dir ) {  // TODO: For now, i disable turning ability. Later can re-incorpriate if got time.
			man.dir = dir;
            var arr:Array = [[1,0],[-1,0],[0,1],[0,-1]]["rlbf".indexOf(man.dir)];
            man.moveArray = arr;
        }else{
            man.dir = dir
            man.moveArray = [0,0]
        }
		
		man.dungeon.wait = GameObject.WAITKEY_STEP_NUM_FRAMES; 
        man.moveArray[2] = GameObject.DEFAULT_STEP_NUM_FRAMES;//移動スピード
        if ( !man.dungeon.checkBumpable(man.mapX + arr[0], man.mapY + arr[1]) ) {
			man.moving = true;
			
		}
	    else {
			man.bumping = true;
		}
		var eFight:FightState = man.bumping ?  man.dungeon.getComponent(man.mapX + arr[0], man.mapY + arr[1], "fight") : null;
		
		// if fighting and cannot move, or bumping into a guy that is fighting and cannot move
		if ( ( fight && !fight.canMove()) || (eFight &&  !eFight.canMove()) ) {
		//	man.moveArray = [0, 0];
			if (man.bumping) {  // potentiality to wish to attack, 
				fight.bumping = true;
				fight.attacking =  man.dungeon.uiTros.radioAttack.selected && (fight.canRollAttackAgainstDirection(FightState.getDirectionIndex(man.moveArray[0], man.moveArray[1]) ));
				fight.resetManuevers();
			}
			else {
				fight.attacking = false;  // imply defense always
				if (man.moving && !fight.lastAttacking ) fight.setManuever( 0);  // if man is moving into empty square and he wasn't attacking in last exchange, imply that he is retreating, else, will reset it to no implied manuever
				else fight.resetManuevers();
 			}
			man.bumping = false;
			man.moving = false;
			if (man.moveArray[0] != 0 || man.moveArray[1] != 0) {
				// determine if fleeing, if, fleeing, hide direction first, to avoid exposing intention to flee
				if (!man.dungeon.checkBumpable(man.mapX + man.moveArray[0], man.mapY + man.moveArray[1])) {
					man.dir = lastDir;
				}
			}
		}
		
		 // don't show any animation if facing direction is the same
		if (man.dir === lastDir && !man.moving && !man.bumping) return; 
		
        if( man.animState == "walk2" ){ man.action("walk1") }
        else{ man.action("walk2") }
    }
}


//敵に関するデータ用クラス(static)
class Enemy{
    static public const anim:Object = {
        "walk":[ [0,"w1"],[16,"w0"],[31,"goto",-1] ]
    }
	
	///*
	// respond to enter frame, currently unused atm because the roguelike isn't realtime.
    static public function frame( enm:GameObject ):void {
		
        if( enm.dungeon.count % 12 == 0 ){
            switch( enm.param.walkType ){
                case "room": if( enm.dungeon.check(enm.dungeon.man.mapX,enm.dungeon.man.mapY,"room").length == 0 ){ random(enm); break; }
                case "chase": chase(enm); break;
                default: random(enm); break;
            }
        }
		
    }
	//*/
	
	// respond to player keyboard movement
	 static public function key(e:KeyboardEvent, enm:GameObject ):void {

		 if (enm.components.fight) enm.components.fight.resetRolls();
		 
            switch( enm.param.walkType ){
                case "room": if( enm.dungeon.check(enm.dungeon.man.mapX,enm.dungeon.man.mapY,"room").length == 0 ){ random(enm); break; }
				case "chase": chase(enm); break;
                default: random(enm); break;
            }
    }
	
	
    static public function walk(enm:GameObject):void {
		
			var fight:FightState =  (enm.components.fight as FightState);
			var lastDir:String = enm.dir;
        var arr:Array = [[1,0],[-1,0],[0,1],[0,-1]]["rlbf".indexOf(enm.dir)];
        enm.moveArray = arr;
        enm.moveArray[2] = GameObject.WAITKEY_STEP_NUM_FRAMES; //移動スピード  // movement tween duration 
       if ( !enm.dungeon.checkBumpable(enm.mapX + arr[0], enm.mapY + arr[1]) ) enm.moving = true;
	   else enm.bumping = true;
	   
	   var eFight:FightState = enm.bumping ?  enm.dungeon.getComponent(enm.mapX + arr[0], enm.mapY + arr[1], "fight") : null;
	   
	  if ( ( fight && !fight.canMove() ) || (eFight && !eFight.canMove() ) ) {
		//	man.moveArray = [0, 0];
			
			if (enm.bumping) {  // potentiality to wish to attack 
				fight.bumping = true;
				fight.attacking =  (fight.canRollAttackAgainstDirection(FightState.getDirectionIndex(enm.moveArray[0], enm.moveArray[1]) ));
			}
			else {
				fight.attacking = false;  // imply defense always
			}
			
			
			enm.bumping = false;
			enm.moving = false;
			if (enm.moveArray[0] != 0 || enm.moveArray[1] != 0) {
				// determine if fleeing, if, fleeing, hide direction first, to avoid exposing intention to flee
				if (!enm.dungeon.checkBumpable(enm.mapX + enm.moveArray[0], enm.mapY + enm.moveArray[1])) {
					enm.dir = lastDir;
				}
			}
		}

	   
    }
	
	/*
	 static public function walk(man:GameObject, dir:String):void{
        if ( true || dir == man.dir ) { 
			man.dir = dir;
            var arr:Array = [[1,0],[-1,0],[0,1],[0,-1]]["rlbf".indexOf(man.dir)];
            man.moveArray = arr;
        }else{
            man.dir = dir
            man.moveArray = [0,0]
        }
        man.moveArray[2] = 6;//移動スピード
        man.moving = true;
        if( man.animState == "walk2" ){ man.action("walk1") }
        else{ man.action("walk2") }
    }
	*/
	
	
    static private function random(enm:GameObject):void{
       // if( enm.dungeon.count % 60 == 0 ){ 
            enm.dir = "rlbf".substr(Math.random()*4,1);
            walk(enm);
       // }
    }
    static private function chase(enm:GameObject):void{
        var dir:Array = [];
        if( enm.dungeon.man.mapX > enm.mapX ){ dir.push("r") }
        else if( enm.dungeon.man.mapX < enm.mapX ){ dir.push("l") }
        if( enm.dungeon.man.mapY > enm.mapY ){ dir.push("b") }
        else if( enm.dungeon.man.mapY < enm.mapY ){ dir.push("f") }
        enm.dir = dir[ int(dir.length*Math.random()) ];
        walk(enm);
    }
}

// Start Riddle of Steel classes

class Manuever {
	public var id:String;
	public var name:String;
	public var cost:int;
	
	
	public var attackTypes:uint;
	public var damageType:int;
	public var defaultTN:int;
	public var customRange:int;
	public var customMinRange:int;
	public var requiredLevel:int;
	public var spamPenalty:int;
	public var spamIndividualOnly:Boolean;
	public var regionMask:uint;
	public var offHanded:Boolean;
	
	public var manueverType:int;
	public static const MANUEVER_TYPE_MELEE:int = 0;
	public static const MANUEVER_TYPE_RANGED:int = 1;
	
	/*
	 * damageType-zero implications: (dpeending on equiped weapon, it can affect the avaiable regions for attack, but definitely the damage type)
	 *
	 * Non-puncturing attack type:  (strike|thrust) + damageType:0
Bash(for blunt weapons...damageType:Bludgeoning,region:Strike), Spike(for blunt weapon...damageType:Bludgeoning,region:Thrust)  - Can aim all regions 
  or Cut(for blades...damageType:Cutting,region:Strike only)
  
  (strike) + damageType:0
  Strike region only for all weapon types. Damage resolved either as blunt bludgeoning or as bladed cutting.
  
  Thrusting attack type (thrust) + damageType:0
  Thrusting region only for all weapon types.  Damage reolved either as blunt bludgeoning  OR as bladed puncturing. 
*/

	public static const DAMAGE_TYPE_CUTTING:int =1;
	public static const DAMAGE_TYPE_PUNCTURING:int = 2;  // used to denote "true" thrusting weapons
	public static const DAMAGE_TYPE_BLUDGEONING:int = 3;
	
	public static const ATTACK_TYPE_STRIKE:uint = 1;
	public static const ATTACK_TYPE_THRUST:uint = 2;
	
	public static const DEFEND_TYPE_OFFHAND:uint = 1;
	public static const DEFEND_TYPE_MASTERHAND:uint = 2;
	
	//public var requirements:uint;
	//public static const REQUIRE_SHIELD:uint = (0 << 1);
	//public static const REQUIRE_FRESH_ROUND:uint = (1 << 1);
	
	
	
	public var index:int;  // for internal use
	
	public function Manuever(id:String, name:String,  cost:int = 0) {
		this.id = id;
		this.name = name;
		this.cost = cost;
		
		//requirements = 0;
		defaultTN = 0;
		customRange = 0;
		customMinRange = 0;
		attackTypes = ATTACK_TYPE_STRIKE | ATTACK_TYPE_THRUST;
		damageType = 0;
		requiredLevel = 0;
		spamPenalty = 0;
		spamIndividualOnly = false;
		regionMask = 0;
		offHanded = false;
		
		manueverType = MANUEVER_TYPE_MELEE;
	}
	
	private static var NUM_ONES:int = 0;
	public static function getRollNumSuccesses(amountDice:int, tn:int):int {
		var result:int;
		NUM_ONES = 0;
		var i:int = amountDice;
		var numSuccesses:int = 0;
		var numStacks:int = 0;
		while (--i > -1) {
			result = (int(Math.random() * 10) + 1);
			if (result == 1) NUM_ONES++;
			numSuccesses += result >= tn ? 1 : 0;
			numStacks += tn > 10 && result == 10 ? 1 : 0;
		}
		
		// not too sure if stacking is handled this way..hmmm..
		while(numStacks > 0) {
			i = numStacks;
			while (--i > -1) {
				result = (int(Math.random() * 10) + 1);
				numSuccesses += result >= tn-10 ? 1 : 0;
			}
		}
		
		return numSuccesses;
	}
	
	public static const ROLL_RESULT_BOTCH:int = -2;
	public static const ROLL_RESULT_DRAW:int = 0;
	public static const ROLL_RESULT_FAILED:int = -1;

	public static function makeChallengeRoll(amountDice:int, tn:int, requiredSuccesses:int):int {
		var numSuccesses:int =  getRollNumSuccesses(amountDice, tn);
		return numSuccesses >= requiredSuccesses ? numSuccesses - requiredSuccesses : NUM_ONES >= (amountDice > 1 ? 2 : 1) ? ROLL_RESULT_BOTCH : ROLL_RESULT_FAILED;
	}
	
	public static function makeIndividualRoll(amountDice:int, tn:int):Object {
		var num:int = getRollNumSuccesses(amountDice, tn);
		return { successes:num , mayBotch: NUM_ONES >= (amountDice > 1 ? 2 : 1)  };
	}
	

	
	public static function isThrustingMotion(targetzone:int):Boolean {
		return false;
	}
	
	// when defending, determining if defensive is exclusively offhanded
	public function isDefensiveOffHanded():Boolean {
		return (attackTypes == DEFEND_TYPE_OFFHAND || offHanded); 
	}
	
	public function _dmgType(val:int):Manuever {
		damageType = val
		return this;
	}
	
	/*
	public function _req(val:int):Manuever {
		requirements = val;
		return this;
	}
	*/
	
	public function _offHanded(val:Boolean):Manuever {
		offHanded = val;
		return this;
	}
	
	public function _tn(val:int):Manuever {
		defaultTN = val;
		return this;
	}
	public function _atkTypes(val:uint):Manuever {
		attackTypes = val;
		return this;
	}
	public function _range(val:int):Manuever {
		customRange = val;
		return this;
	}
	public function _rangeMin(val:int):Manuever {
		customMinRange = val;
		return this;
	}
	
	public function _lev(val:int):Manuever {
		requiredLevel = val;
		return this;
	}
	public function _spamPenalize(val:int, spamIndividualOnly:Boolean=false):Manuever {
		spamPenalty = val;
		this.spamIndividualOnly = spamIndividualOnly;
		return this;
		
	}
	
	public function _regions(val:uint):Manuever {
		regionMask  = val;
		return this;
	}
	
	// custom method(s) to filter the manuever
	public function _customRequire():Manuever {
		
		return this;
	}
	
	// custom method(s) for pre-resolving a given roll...
	public function _customPreResolve():Manuever {  
		
		return this;
	}
	
	// custom method(s) for resolving a given roll...to determine whether a hit occurs or not, the results of cp, and the intiaitive gain/lost as a result
	public function _customResolve():Manuever {  
		
		return this;
	}
	
	// custom modifer method to determine amount of raw damage level dealt
	public function _customDamage():Manuever {
		
		return this;
	}
	
	// custom modifer method to determine reflex amount
	public function _customReflex():Manuever {
		
		return this;
	}
	
	// custom modifer method to determine range amount of weapon
	public function _customRange():Manuever {
		
		return this;
	}
	
	
	// custom method to control splitting of maneuvers (for composite manuevers)
	public function _customSplit():Manuever {
		
		return this;
	}
	
	
	
}

class Profeciency {
	public var id:String;
	public var name:String;
	public var offensiveManuevers:uint;
	public var defensiveManuevers:uint;
	public var atkCosts:Object;
	public var defCosts:Object;
	public var defaults:Object;
	
	public var index:int;  // for internal use

	public function Profeciency(id:String, name:String, offensiveManuevers:uint, defensiveManuevers:uint, atkCosts:Object=null, defCosts:Object=null, defaults:Object=null) {
		this.id = id;
		this.name = name;
		this.offensiveManuevers = offensiveManuevers;
		this.defensiveManuevers = defensiveManuevers;
		this.atkCosts = atkCosts ? atkCosts : { };
		this.defCosts = defCosts ? defCosts : { };
		this.defaults = defaults ? defaults : { };
	}
}

class ManueverStack {
	// an array containing generic objects for attack manuevers
	// { from:entity, to:entity, targetZone:??, numDice:?,  tn:?, reflexScore:,, manuever:, defManuever:{} }  // for offensive manuevers to be stacked
	// For defManuever: {  numDice, manuever }
	
	public var stack:Array = [];
	//public var stackIndex:int = 0;
	
	public function reset():void {
		//stackIndex = 0;
		stack.length = 0;
	}
	
	public function pushManuever(manueverObj:Object):void {
		//stack[stackIndex++] = manueverObj;
		stack.push( manueverObj );
		
	}
	
	public function sortOnLowestToHighest(property:String):void {
		var referArr:Array = stack.sortOn(property);
		sortInto(referArr);
	}
	
	public function sortOnHighestToLowest(property:String):void {
		var referArr:Array = stack.sortOn(property, Array.DESCENDING);
		sortInto(referArr);
	}
	
	private function sortInto(referArr:Array):void {
		var len:int = referArr.length;
		for (var i:int = 0; i < len; i++) {
			stack[i] = referArr[i];
		}
	}
}

class ManueverSheet {
		
		public static var offensiveMelee:Array = [
			new Manuever("cut", "Cut")._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)
			,new Manuever("cut2", "Greater Cut", 1)._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customDamage()
		,new Manuever("bash", "Bash")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)
			,new Manuever("bash2", "Greater Bash", 1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customDamage()
			,new Manuever("beat", "Beat")._lev(4)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customRequire()._customResolve()
			,new Manuever("bindstrike", "Bind and Strike")._customRequire()._customResolve()
						,new Manuever("thrust", "Thrust")._customReflex()._dmgType(Manuever.DAMAGE_TYPE_PUNCTURING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)
		,new Manuever("spike", "Spike")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)
		,new Manuever("spike2", "Greater Spike", 1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)._customDamage()
					,new Manuever("punch", "Punch")._tn(5)._range(1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage()
		,new Manuever("kick", "Kick")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._tn(7)._customDamage()._range(2)._regions(0)._rangeMin(1)
		
		,new Manuever("disarm", "Disarm", 1)._lev(4)._customRequire()._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customResolve()
			,new Manuever("doubleattack", "Double Attack")._customRequire()._customSplit()
			,new Manuever("drawcut", "Draw Cut")._lev(2)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._customDamage()._customRange()._customRequire()
			,new Manuever("evasiveattack", "Evasive Attack")._lev(6)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customRequire()._customPreResolve()
		,new Manuever("feintandthrust", "Feint and Thrust")._lev(3)._atkTypes(Manuever.ATTACK_TYPE_THRUST)._customPreResolve()._spamPenalize(1, true)  //_dmgType(Manuever.DAMAGE_TYPE_PUNCTURING).
		,new Manuever("feintandcut", "Feint and Cut")._lev(5)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customPreResolve()._spamPenalize(1, true)  //_dmgType(Manuever.DAMAGE_TYPE_CUTTING)
		,new Manuever("grapple", "Grapple")._tn(5)._customResolve()
		//,new Manuever("halfsword", "Half Sword")._customResolve()
		,new Manuever("headbutt", "Head Butt")._tn(6)._range(1)._regions(0)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage()  // todo regions
		,new Manuever("hook", "Hook")._customResolve()._regions(0)
		,new Manuever("masterstrike", "Master Strike")._lev(15)._customRequire()._customSplit()
		,new Manuever("murderstroke", "Murder Stroke")._lev(5)._tn(6)._range(1)._customRequire()._regions(0)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customPreResolve()._customDamage()
		,new Manuever("pommelbash", "Pommel Bash")._lev(5)._tn(7)._range(1)._customRequire()._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage()
		,new Manuever("quickdraw", "Quick Draw")._lev(6)._customResolve()
		,new Manuever("blockstrike", "Simultaenous Block and Strike")._customRequire()._customSplit()
		,new Manuever("stopshort", "Stop Short")._lev(3)._customResolve()._spamPenalize(1)	
		,new Manuever("toss", "Toss")._customRequire()._tn(7)._customResolve()
		,new Manuever("twitching", "Twitching")._lev(8)._customSplit()._customResolve()
		];
		
		public static var defensiveMelee:Array = [ // NOTE: full evade must always be the first. In fact, first 3 should be evasive manuevers by convention
			new Manuever("fullevade", "Full Evasion")._tn(4)  // staionery full evade is possible (ie. didn't displace)...but need terrain roll TN7 saving throw
			,new Manuever("partialevade", "Partial Evasion")._tn(7)._customResolve()  // partial buying initiative will cost 2cp only, non-standard
			,new Manuever("duckweave", "Duck and Weave")._tn(9)._customResolve()
			,new Manuever("block", "Block")._atkTypes(Manuever.DEFEND_TYPE_OFFHAND)._customRequire()
			,new Manuever("blockopenstrike", "Block Open and Strike")._lev(6)._atkTypes(Manuever.DEFEND_TYPE_OFFHAND)._customResolve()
			,new Manuever("counter", "Counter")._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("disarm", "Disarm", 1)._lev(4)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("expulsion", "Expulsion")._lev(5)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)
			,new Manuever("grapple",  "Grapple")._tn(5)._customResolve()
		//	,new Manuever("halfsword", "Half Sword").
			,new Manuever("masterstrike", "Master Strike")._lev(15)._customRequire()._customSplit()
			,new Manuever("overrun", "Overrun")._lev(12)._tn(7)._customSplit()
			,new Manuever("parry", "Parry")._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)
			,new Manuever("quickdraw", "Quick Draw")._lev(6)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("rota", "Rota")._customRequire()._lev(3)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
		];
		public static var offensiveMeleeHash:Object = createHashIndex(offensiveMelee);
		public static var defensiveMeleeHash:Object = createHashIndex(defensiveMelee);
		
		
		
		public static function createHashIndex(arr:Array):Object {
			var obj:Object = { };
			var len:int = arr.length;
			for (var i:int = 0; i < len; i++) {
				obj[arr[i].id] = i;
			}
			return obj;
		}
		
		
		
		//public static function createOffensive
		
		public static function getMaskWithHashIndexer(arrOfIds:Array, hash:Object):uint {
			var val:uint = 0;
			var i:int = arrOfIds.length;
			while (--i > -1) {
				var prop:String =  arrOfIds[i];
				if (hash[prop] != null) val |= (1 << hash [prop ] );
			}
			return val;
		}
		
		public static function createOffensiveMeleeMaskFor(arr:Array):uint {
			return getMaskWithHashIndexer(arr, offensiveMeleeHash);
		}
		
		public static function createDefensiveMeleeMaskFor(arr:Array):uint {
			return getMaskWithHashIndexer(arr, defensiveMeleeHash);
		}
}

class ProfeciencySheet {
	
	//http://knight.burrowowl.net/doku.php?id=rules:proficiencies
	public static var LIST:Array = [
		new Profeciency("swordshield", "Sword and Shield", ManueverSheet.createOffensiveMeleeMaskFor(["bindstrike", "cut", "cut2", "feintcut", "feintthrust", "blockstrike", "thrust", "thrust2", "twitching", "masterstrike", "disarm"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "blockopenstrike", "counter", "parry", "disarm", "masterstrike", "overrun", "parry", "rota"]), { "blockopenstrike":2, "masterstrike":6 }, { "blockopenstrike":2, "counter":[3, 2], "disarm":3, "masterstrike":6, "overrun":4, "parry":[1, 0], "rota":2 }, { "caserapiers":4, "cutthrust":2, "dagger":2, "doppelhander":4, "greatlongsword":2, "massweaponshield":1, "polearms":4, "poleaxe":4, "pugilism":4, "rapier":4, "wrestling":4 } ),
		new Profeciency("cutthrust", "Cut and Thrust", ManueverSheet.createOffensiveMeleeMaskFor(["beat", "bindstrike", "cut", "disarm", "doubleattack", "drawcut", "feint", "masterstrike", "quickdraw", "blockstrike", "stopshort", "thrust", "toss", "twitch"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "counter", "disarm", "expulsion", "grapple", "masterstrike", "overrun", "parry", "rota"]), { "disarm":1, "masterstrike":6, "quickdraw":2, "twitch":2 }, { "counter":2, "disarm":3, "expulsion":2, "grapple":2, "masterstrike":6, "overrun":3 }, { "caserapiers":3, "dagger":2, "doppelhander":4, "greatlongsword":3, "massweaponshield":2, "polearms":3, "poleaxe":4, "pugilism":2, "rapier":2, "swordshield":2, "wrestling":3 } ),
		new Profeciency("rapier", "Rapier", ManueverSheet.createOffensiveMeleeMaskFor(["beat", "bindstrike", "disarm", "doubleattack", "feintthrust", "masterstrike", "blockstrike", "stopshort", "thrust", "toss"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "counter", "disarm", "expulsion", "grapple", "masterstrike", "overrun", "parry"]), { "disarm":1, "feintthrust":1, "masterstrike":6 }, { "counter":3, "disarm":3, "expulsion":2, "grapple":2, "masterstrike":6, "overrun":3, "parry":0 }, {  "caserapiers":1, "cutthrust":2, "dagger":2, "doppelhander":4, "greatlongsword":4, "massweaponshield":4, "polearms":3, "poleaxe":4, "pugilism":2, "swordshield":3, "wrestling":3 }  ),
		new Profeciency("pugilism", "Pugilism", ManueverSheet.createOffensiveMeleeMaskFor(["disarm", "grapple", "kick", "punch"]), ManueverSheet.createDefensiveMeleeMaskFor(["disarm", "grapple", "parry"]), { "disarm":2, "grapple":[2,4], "kick":1  }, { "disarm":4, "grapple":2 }, { "caserapiers":4, "cutthrust":4,  "dagger":1, "doppelhander":4, "greatlongsword":4, "massweaponshield":3, "polearms":4, "poleaxe":4, "rapier":3, "swordshield":4, "wrestling":1 })
	]
	
	public static var listHashIndexer:Object = ManueverSheet.createHashIndex(LIST);
	public static function getProfeciency(id:String):Profeciency {
		return LIST[listHashIndexer[id]];
	}
	
	/*
	public static function getProfManueverCost(id:String):int {
		
	}
	*/
	
	public static function resolveProfManueverCostChoice(id:String, arr:Array, components:Object):int {
		if (id === "counter") {
			var charSheet:CharacterSheet = components.char;
			return charSheet.weaponOffhand != null && charSheet.weaponOffhand.shield ? arr[0] : arr[1];
		}
		return arr[0];
	}
}

class Weapon {

	public var profeciencies:Array;
	
	// ATN/Damage :  1 is for striking/swinging  or cutting(if damage3 is not undefined...used for bludgeoning) attacks,  2 is for spiking/thrusting attacks
	public var ATN:int;
	public var ATN2:int;
	public var damage:int;
	public var damage2:int;
	public var damage3:int;
	public var DTN:int;	// melee DTN
	public var DTNt:int;  // melee DTN against thrusts of 4 cp or less
	public var DTN2:int; // ranged DTN
	public var name:String;
	public var drawCutModifier:int;
	public var attrBaseIndex:int;
	public var dualHanded:Boolean;
	public var rangedWeapon:Boolean;
	public var cpPenalty:Number;
	public var movePenalty:Number;
	public var shield:Boolean;  // does this function as a shield for Block manuever?
	public var shieldLimit:int;  // when up against a certain amount of CPs, then it can function as a Blockgin shield, otherwise, no Block manuever is available.
	public var blunt:Boolean;  // flag to treat always as bludgeoning damage regardless, even for spiking/thrusting maoves
	
	public var range:int;
	
	public static const ATTR_BASE_STRENGTH:int = 0;

	public function Weapon(name:String, profGroups:Array) {
		this.name = name;
		this.profeciencies = profGroups;
		// ManueverSheet.getMaskWithHashIndexer(profGroups, ProfeciencySheet.listHashIndexer);
		attrBaseIndex = ATTR_BASE_STRENGTH;
		drawCutModifier = 0;
		damage = 0;
		damage2 = 0;
		damage3 = 0;
		ATN = 0;
		ATN2 = 0;
		DTN = 0;
		DTN2 = 0;
		dualHanded = false;
		rangedWeapon = false;
		shield = false;
		shieldLimit = 0;
		cpPenalty = 0;
		movePenalty = 0;
		blunt = false;
		
	
	}
	


	
	public static function createDyn(name:String, profGroups:Array, properties:Object):Weapon {
		var weap:Weapon = new Weapon(name, profGroups);
		for (var p:String in properties) {
			weap[p] = properties[p];
		}
		return weap;
	}
	
	

}

class WeaponSheet {
	
	public static function createHashLookupViaName(arr:Array):Object {
		var obj:Object = { };
		var len:int = arr.length;
		for (var i:int = 0; i < len; i++) {
			var lookinFor:Object = arr[i];
			obj[lookinFor.name] = lookinFor;
		}
		return obj;
	}
		
	//http://knight.burrowowl.net/doku.php?id=equipment:weapons
	public static var LIST:Array = [
		//Weapon.createDyn("Akinakes", "
		Weapon.createDyn("Kick", ["pugilism"], { "range":0, "ATN":7, "DTN":8,   "damage":-1, "blunt":true  } )
		,Weapon.createDyn("Punch", ["pugilism"], { "range":0, "ATN":5, "DTN":6,   "damage":-2, "blunt":true  } )
		
		,Weapon.createDyn("Short Sword", ["cutthrust", "swordshield"], { "range":1, "ATN":7, "ATN2":5, "DTN":7,   "damage": -1, "damage2":1  } )
		,Weapon.createDyn("Gladius", ["swordshield"], { "range":1, "ATN":6, "ATN2":6, "DTN":7,   "damage":0, "damage2":1, "drawCutModifier":0  } )
		,Weapon.createDyn("Arming Sword", ["swordshield", "cutthrust"], { "range":2, "ATN":6, "ATN2":7, "DTN":6,   "damage":1, "damage2":0, "drawCutModifier":0  } )
		,Weapon.createDyn("Rapier", ["rapier", "caserapiers"], { "range":3, "ATN":7, "ATN2":5, "DTN":8, "DTNt":6,  "damage": -3, "damage2":2, "drawCutModifier":1  } )
		
		,Weapon.createDyn("Arming Glove", ["swordshield", "massweaponshield"], { "range":0, "shield":true, "shieldLimit":4, "ATN":5, "DTN":7,  "damage":0, "blunt":true } )
		,Weapon.createDyn("Hand Shield", ["swordshield", "massweaponshield"], { "shield":true, "DTN":7, "DTN2":9 } )
		,Weapon.createDyn("Small Shield", ["swordshield", "massweaponshield"], { "shield":true, "DTN":6, "DTN2":8 } )
		,Weapon.createDyn("Medium Shield", ["swordshield", "massweaponshield"], { "shield":true, "DTN":5, "DTN2":7, "cpPenalty":0.5, "movePenalty":0.5 } )
		,Weapon.createDyn("Large Shield", ["swordshield", "massweaponshield"], {"shield":true, "DTN":5, "DTN2":6, "cpPenalty":0.5, "movePenalty":1} )
	
	]
	public static var HASH:Object = createHashLookupViaName(LIST);
	
	public static function find(name:String):Weapon  {
		return HASH[name];
	}
}


// body zone definition
class ZoneBody {
	
	public var name:String;  // the name of the zone
	public var parts:Array;  // the parts, according to ids
	public var partWeights:Vector.<Number>;  // distribution of parts for probability
	
	public static function create(name:String, partWeights:Vector.<Number>, parts:Array):ZoneBody {
		var zb:ZoneBody = new ZoneBody();
		zb.name = name;
		zb.parts = parts;
		zb.partWeights = partWeights;
		return zb;
	}
}

// Body char definition
class BodyChar {  // base class to handle different body types later (ie. for non-humanoids)
	public var zones:Vector.<ZoneBody>;   // zones for bladed attacks
	public var zonesB:Vector.<ZoneBody>;  // zones for blunt attacks
	public var thrustStartIndex:int; // at what index attack zones become thrusting/spiking motions.
	public var centerOfMass:Array;  // the zone indices that indicate the center of mass of the given body
	
	// damage table for different body parts
	public var partsCut:Object;  
	public var partsPuncture:Object;
	public var partsBludgeon:Object;
	
}

class HumanoidBody extends BodyChar {  
	public static const ZONE_I:int = 0;
	public static const ZONE_II:int = 1;
	public static const ZONE_III:int = 2;
	public static const ZONE_IV:int = 3;
	public static const ZONE_V:int = 4;
	public static const ZONE_VI:int = 5;
	public static const ZONE_VII:int = 6;
	public static const ZONE_VIII:int = 7;
	public static const ZONE_IX:int = 8;
	public static const ZONE_X:int = 9;
	public static const ZONE_XI:int = 10;
	public static const ZONE_XII:int = 11;
	public static const ZONE_XIII:int = 12;
	public static const ZONE_XIV:int = 13;

	public static const CENTER_OF_MASS:Array = [ZONE_III, ZONE_II];
	
	private static var INSTANCE:HumanoidBody;
	public static function getInstance():HumanoidBody {
	    return INSTANCE != null ? INSTANCE : (INSTANCE = new HumanoidBody());
	}
	
	public function HumanoidBody() {
		super();
		
		// http://knight.burrowowl.net/doku.php?id=rules:master_damage_table
		// d is for destruction level.   1, destroy part.  2,  character dies
		partsBludgeon = {"foot":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"KD":3,"BL":0,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"KD":1,"BL":0,"shock":6,"shockWP":0,"pain":8,"painWP":1},{"KD":-1,"BL":1,"shock":9,"shockWP":0,"pain":10,"painWP":1}],"shin_and_lower_leg":[{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":2,"BL":0,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":0,"shock":6,"shockWP":0,"pain":7,"painWP":1},{"KD":-3,"BL":2,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"KD":-1,"BL":5,"shock":10,"shockWP":0,"pain":12,"painWP":1}],"knee_and_nearby_areas":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":2,"shock":8,"shockWP":0,"pain":8,"painWP":1},{"KD":-5,"BL":6,"shock":10,"shockWP":0},{"KD":-1,"BL":8,"shock":15,"shockWP":0,"pain":12,"painWP":1}],"thigh":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"KD":2,"BL":0,"shock":5,"shockWP":0,"pain":4,"painWP":1},{"KD":0,"BL":0,"shock":7,"shockWP":0,"pain":7,"painWP":1},{"KD":-4,"BL":3,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"KD":-1,"BL":7,"shock":10,"shockWP":0,"pain":12,"painWP":1}],"inner_thigh":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"KD":2,"BL":0,"shock":5,"shockWP":0,"pain":4,"painWP":1},{"KD":0,"BL":0,"shock":7,"shockWP":0,"pain":7,"painWP":1},{"KD":-4,"BL":3,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"KD":-1,"BL":7,"shock":10,"shockWP":0,"pain":12,"painWP":1}],"hip":[{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":0,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"KD":-1,"BL":2,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":10,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":20,"shock":-1,"shockWP":0,"pain":13,"painWP":1,"d":1}],"groin":[{"BL":0,"shock":7,"shockWP":0,"pain":9,"painWP":1},{"ko":0,"BL":0,"shock":9,"shockWP":0,"pain":10,"painWP":1},{"ko":-2,"BL":3,"shock":11,"shockWP":0,"pain":15,"painWP":1},{"ko":-1,"BL":18,"shock":-1,"shockWP":0,"pain":-1,"painWP":0},{"BL":20,"shock":-1,"shockWP":0,"pain":-1,"painWP":0,"d":2}],"abdomen":[{"BL":0,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"ko":3,"BL":0,"shock":7,"shockWP":0,"pain":6,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":8,"painWP":1},{"BL":8,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"ko":-3,"BL":15,"shock":-1,"shockWP":0,"pain":15,"painWP":1}],"ribcage":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"ko":2,"BL":1,"shock":8,"shockWP":0,"pain":6,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"ko":-3,"BL":9,"shock":-1,"shockWP":0,"pain":15,"painWP":1}],"upper_abdomen":[{"BL":0,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"ko":3,"BL":0,"shock":7,"shockWP":0,"pain":6,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":8,"painWP":1},{"BL":8,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"ko":-3,"BL":15,"shock":-1,"shockWP":0,"pain":15,"painWP":1}],"chest":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"ko":2,"BL":1,"shock":8,"shockWP":0,"pain":6,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"ko":0,"BL":9,"shock":-1,"shockWP":0,"pain":15,"painWP":1}],"upper_body":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"ko":2,"BL":1,"shock":8,"shockWP":0,"pain":6,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"ko":-3,"BL":9,"shock":-1,"shockWP":0,"pain":15,"painWP":1}],"neck":[{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":1,"shock":7,"shockWP":0,"pain":9,"painWP":1},{"ko":0,"BL":3,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":3,"shock":-1,"shockWP":0,"pain":15,"painWP":1},{}],"face":[{"ko":3,"BL":0,"shock":5,"shockWP":1,"pain":0,"painWP":0},{"ko":1,"BL":1,"shock":8,"shockWP":0,"pain":6,"painWP":1},{"BL":4,"shock":10,"shockWP":0,"pain":0,"painWP":0},{"ko":-3,"BL":6,"shock":12,"shockWP":0,"pain":9,"painWP":1},{"d":2}],"lower_head":[{"ko":3,"BL":0,"shock":5,"shockWP":1,"pain":0,"painWP":0},{"ko":1,"BL":1,"shock":8,"shockWP":0,"pain":6,"painWP":1},{"BL":4,"shock":10,"shockWP":0,"pain":0,"painWP":0},{"ko":-3,"BL":6,"shock":12,"shockWP":0,"pain":9,"painWP":1},{"d":2}],"upper_head":[{"ko":2,"BL":0,"shock":8,"shockWP":1,"pain":5,"painWP":1},{"ko":0,"BL":3,"shock":8,"shockWP":0,"pain":8,"painWP":1},{"ko":-3,"BL":4,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":6,"shock":-1,"shockWP":0,"pain":-1,"painWP":0},{"d":2}],"upper_arm_and_shoulder":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":5,"shockWP":0,"pain":5,"painWP":1},{"BL":1,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":5,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"BL":10,"shock":13,"shockWP":0,"pain":12,"painWP":1}],"hand":[{"BL":0,"shock":4,"shockWP":1,"pain":0,"painWP":0},{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":0,"shock":7,"shockWP":1,"pain":5,"painWP":1},{"BL":1,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":3,"shock":9,"shockWP":0,"pain":9,"painWP":1}],"forearm":[{"BL":0,"shock":4,"shockWP":1,"pain":0,"painWP":0},{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":1,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":2,"shock":8,"shockWP":0,"pain":8,"painWP":1},{"BL":3,"shock":10,"shockWP":0,"pain":10,"painWP":1}],"elbow":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":5,"shockWP":0,"pain":4,"painWP":1},{"BL":0,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":1,"shock":8,"shockWP":0,"pain":7,"painWP":1},{"BL":3,"shock":9,"shockWP":0,"pain":10,"painWP":0}]};

		partsCut ={"foot":[{"BL":0,"shock":3,"shockWP":1,"pain":2,"painWP":1},{"BL":1,"shock":3,"shockWP":0,"pain":3,"painWP":1},{"KD":3,"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":1,"BL":5,"shock":6,"shockWP":0,"pain":6,"painWP":1},{"KD":0,"BL":10,"shock":9,"shockWP":0,"pain":8,"painWP":1}],"shin_and_lower_leg":[{"BL":0,"shock":3,"shockWP":0,"pain":2,"painWP":1},{"KD":2,"BL":2,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":4,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"KD":-2,"BL":8,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"KD":0,"BL":13,"shock":9,"shockWP":0,"pain":10,"painWP":1}],"knee_and_nearby_areas":[{"BL":0,"shock":5,"shockWP":1,"pain":3,"painWP":1},{"BL":2,"shock":5,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":4,"shock":8,"shockWP":0,"pain":8,"painWP":1},{"KD":-5,"BL":8,"shock":10,"shockWP":0,"pain":13,"painWP":1},{"KD":0,"BL":13,"shock":12,"shockWP":0,"pain":12,"painWP":1}],"thigh":[{"BL":1,"shock":4,"shockWP":1,"pain":3,"painWP":1},{"KD":2,"BL":2,"shock":2,"shockWP":0,"pain":4,"painWP":1},{"KD":2,"BL":4,"shock":5,"shockWP":0,"pain":4,"painWP":1},{"KD":2,"BL":4,"shock":5,"shockWP":0,"pain":4,"painWP":1},{"KD":2,"BL":4,"shock":5,"shockWP":0,"pain":4,"painWP":1}],"inner_thigh":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":6,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":9,"shock":5,"shockWP":0,"pain":16,"painWP":1},{"BL":12,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":17,"shock":7,"shockWP":0,"pain":10,"painWP":1,"d":2}],"groin":[{"BL":6,"shock":9,"shockWP":0,"pain":9,"painWP":1},{"BL":9,"shock":9,"shockWP":0,"pain":10,"painWP":1},{"BL":12,"shock":10,"shockWP":0,"pain":12,"painWP":1,"d":1},{"BL":18,"shock":-1,"shockWP":0,"pain":-1,"painWP":0},{"BL":20,"shock":-1,"shockWP":0,"pain":-1,"painWP":0,"d":2}],"hip":[{"BL":0,"shock":4,"shockWP":1,"pain":3,"painWP":1},{"BL":2,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":4,"shock":5,"shockWP":0,"pain":7,"painWP":1},{"KD":-2,"BL":8,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"KD":-1,"BL":12,"shock":10,"shockWP":0,"pain":12,"painWP":1}],"abdomen":[{"BL":1,"shock":2,"shockWP":0,"pain":5,"painWP":1},{"BL":3,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"BL":7,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":10,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":20,"shock":-1,"shockWP":0,"pain":-1,"painWP":0}],"ribcage":[{"BL":0,"shock":2,"shockWP":0,"pain":4,"painWP":1},{"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":3,"shock":8,"shockWP":0,"pain":7,"painWP":1},{"BL":9,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":20,"d":2}],"chest":[{"BL":0,"shock":2,"shockWP":0,"pain":4,"painWP":1},{"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":3,"shock":8,"shockWP":0,"pain":7,"painWP":1},{"BL":9,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":20,"d":2}],"upper_arm_and_shoulder":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":4,"shock":5,"shockWP":0,"pain":8,"painWP":1},{"BL":8,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":12,"shock":13,"shockWP":0,"pain":14,"painWP":1}],"shoulder":[{"BL":1,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":5,"shock":6,"shockWP":0,"pain":7,"painWP":1},{"BL":10,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":25,"shock":10,"shockWP":0,"pain":11,"painWP":1}],"neck":[{"BL":1,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":4,"shock":7,"shockWP":0,"pain":10,"painWP":1},{"BL":9,"shock":10,"shockWP":0,"pain":11,"painWP":1},{"BL":20,"shock":13,"shockWP":0,"pain":14,"painWP":1},{"d":2}],"face":[{"BL":0,"shock":5,"shockWP":1,"pain":0,"painWP":0},{"BL":2,"shock":8,"shockWP":0,"pain":5,"painWP":1},{"BL":5,"shock":1,"shockWP":1,"pain":7,"painWP":1},{"BL":7,"shock":10,"shockWP":0,"pain":10,"painWP":1},{"d":2}],"lower_head":[{"BL":0,"shock":5,"shockWP":1,"pain":0,"painWP":0},{"BL":2,"shock":8,"shockWP":0,"pain":5,"painWP":1},{"BL":5,"shock":1,"shockWP":1,"pain":7,"painWP":1},{"BL":7,"shock":10,"shockWP":0,"pain":10,"painWP":1},{"d":2}],"upper_head":[{"BL":3,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":3,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":4,"shock":10,"shockWP":0,"pain":12,"painWP":1},{"ko":0,"BL":10,"shock":-1,"shockWP":0,"pain":-1,"painWP":0},{"d":2}],"hand":[{"BL":0,"shock":7,"shockWP":1,"pain":4,"painWP":1},{"BL":2,"pain":4,"painWP":1},{"BL":6,"shock":9,"shockWP":1,"pain":6,"painWP":1},{"BL":8,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"BL":10,"shock":10,"shockWP":0,"pain":11,"painWP":1,"d":1}],"forearm":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":7,"painWP":1},{"BL":4,"shock":5,"shockWP":0,"pain":7,"painWP":1},{"BL":6,"shock":8,"shockWP":0,"pain":8,"painWP":1},{"BL":12,"shock":10,"shockWP":0,"pain":12,"painWP":1,"d":1}],"elbow":[{"BL":0,"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":3,"shock":6,"shockWP":0,"pain":6,"painWP":1},{"BL":6,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"BL":12,"shock":10,"shockWP":0,"pain":10,"painWP":1}]};
		
		
		partsPuncture = {"foot":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":0,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"KD":3,"BL":2,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"KD":-1,"BL":3,"shock":7,"shockWP":0,"pain":7,"painWP":1},{"KD":-1,"BL":3,"shock":7,"shockWP":0,"pain":7,"painWP":1}],"shin_and_lower_leg":[{"BL":0,"shock":4,"shockWP":0,"pain":4,"painWP":1},{"KD":2,"BL":1,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":2,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"KD":-2,"BL":2,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"KD":0,"BL":4,"shock":7,"shockWP":0,"pain":8,"painWP":1}],"knee_and_nearby_area":[{"BL":0,"shock":5,"shockWP":1,"pain":5,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"KD":0,"BL":3,"shock":6,"shockWP":0,"pain":6,"painWP":1},{"KD":-2,"BL":4,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"KD":-5,"BL":6,"shock":9,"shockWP":0,"pain":11,"painWP":1}],"thigh":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"KD":2,"BL":1,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"KD":0,"BL":2,"shock":5,"shockWP":0,"pain":5,"painWP":1},{"KD":-2,"BL":4,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":8,"shock":5,"shockWP":0,"pain":7,"painWP":1}],"groin":[{"BL":6,"shock":7,"shockWP":0,"pain":9,"painWP":1},{"BL":8,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":10,"shock":10,"shockWP":0,"pain":15,"painWP":1},{"shock":-1,"shockWP":0,"pain":-1,"painWP":0},{"BL":15,"shock":-1,"shockWP":0,"pain":-1,"painWP":0}],"hip":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":1,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":9,"painWP":1},{"KD":-2,"BL":6,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"KD":0,"BL":10,"shock":10,"shockWP":0,"pain":12,"painWP":1}],"flesh_to_the_side":[{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1}],"lower_abdomen":[{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":6,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"BL":8,"shock":7,"shockWP":0,"pain":9,"painWP":1},{"shock":10,"shockWP":0,"pain":12,"painWP":1},{"BL":18,"shock":-1,"shockWP":0,"pain":-1,"painWP":0}],"upper_abdomen":[{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":8,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":10,"shock":8,"shockWP":0,"pain":10,"painWP":1},{"BL":13,"shock":13,"shockWP":0,"pain":15,"painWP":1},{"BL":19,"shock":-1,"shockWP":0,"pain":-1,"painWP":0}],"chest":[{"BL":0,"shock":9,"shockWP":1,"pain":5,"painWP":1},{"BL":4,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"BL":8,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":19,"shock":13,"shockWP":0,"pain":13,"painWP":1,"d":2},{"d":2}],"collar_and_throat":[{"BL":2,"shock":4,"shockWP":0,"pain":5,"painWP":1},{"BL":6,"shock":7,"shockWP":0,"pain":6,"painWP":1},{"shock":13,"shockWP":0,"pain":15,"painWP":1},{"BL":15,"shock":-1,"shockWP":0,"pain":20,"painWP":1},{"d":2}],"face":[{"BL":1,"shock":7,"shockWP":1,"pain":4,"painWP":1},{"BL":2,"shock":6,"shockWP":0,"pain":6,"painWP":1},{"ko":-3,"BL":8,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"ko":0,"BL":19,"shock":13,"shockWP":0,"pain":13,"painWP":0},{"d":2}],"head":[{"BL":1,"shock":7,"shockWP":1,"pain":4,"painWP":1},{"BL":2,"shock":6,"shockWP":0,"pain":6,"painWP":1},{"ko":-3,"BL":8,"shock":10,"shockWP":0,"pain":9,"painWP":1},{"ko":0,"BL":19,"shock":13,"shockWP":0,"pain":13,"painWP":0},{"d":2}],"hand":[{"BL":0,"shock":6,"shockWP":1,"pain":5,"painWP":1},{"BL":0,"shock":3,"shockWP":0,"pain":4,"painWP":1},{"BL":2,"shock":9,"shockWP":1,"pain":6,"painWP":1},{"BL":5,"shock":7,"shockWP":0,"pain":9,"painWP":1},{"BL":9,"shock":8,"shockWP":0,"pain":9,"painWP":1}],"forearm":[{"shock":5,"shockWP":1,"pain":4,"painWP":1},{"BL":1,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":2,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":6,"shock":7,"shockWP":0,"pain":8,"painWP":1},{"BL":7,"shock":8,"shockWP":0,"pain":9,"painWP":1}],"elbow":[{"BL":0,"shock":6,"shockWP":1,"pain":5,"painWP":1},{"BL":0,"shock":4,"shockWP":0,"pain":6,"painWP":1},{"BL":3,"shock":6,"shockWP":0,"pain":7,"painWP":1},{"BL":5,"shock":8,"shockWP":0,"pain":9,"painWP":1},{"BL":7,"shock":9,"shockWP":0,"pain":11,"painWP":1}],"upper_arm":[{"BL":0,"shock":4,"shockWP":1,"pain":4,"painWP":1},{"BL":1,"shock":3,"shockWP":0,"pain":5,"painWP":1},{"BL":3,"shock":5,"shockWP":0,"pain":6,"painWP":1},{"BL":5,"shock":6,"shockWP":0,"pain":7,"painWP":1},{"BL":7,"shock":7,"shockWP":0,"pain":8,"painWP":1}]}

		

		// http://knight.burrowowl.net/doku.php?id=rules:attack_locations
		zones = new Vector.<ZoneBody>(14, true);  // cutting and thrusting(puncturing) damage to body
		zonesB = new Vector.<ZoneBody>(14, true);  // bludgeonoing and spiking damage to body
		thrustStartIndex = ZONE_VIII;
		
		// Bladed
		// swings
		zones[ZONE_I] = ZoneBody.create("to the Lower Legs", new <Number>[1,3,2], ["foot", "shin_and_lower_leg", "knee_and_nearby_areas"] );
		zones[ZONE_II] = ZoneBody.create("to the Upper Legs", new < Number > [2, 3, 1], ["knee_and_nearby_areas", "thigh", "hip"] );
		zones[ZONE_III] = ZoneBody.create("for Horizontal Swing", new < Number > [1, 1, 1, 2, 1], ["hip", "upper_abdomen", "lower_abdomen", "ribcage", "arms"] );
		zones[ZONE_IV] = ZoneBody.create("for Overhand Swing", new < Number > [2, 1, 1, 1, 1], ["upper_arm_and_shoulder", "chest", "neck", "lower_head", "upper_head"] );
		zones[ZONE_V] = ZoneBody.create("for Downward Swing from Above", new < Number > [3, 1, 2], ["upper_head", "lower_head", "shoulder" ] );
		zones[ZONE_VI] = ZoneBody.create("for Upward Swing from Below", new < Number > [3, 1, 1, 1], ["inner_thigh", "groin", "abdomen", "chest" ] );
		zones[ZONE_VII] = ZoneBody.create("to the Arms", new < Number > [1, 2, 1, 2], ["hand", "forearm", "elbow", "upper_arm_and_shoulder" ] );
		// thrusts
		zones[ZONE_VIII] = ZoneBody.create("to the Lower Legs", new < Number > [1, 3, 1, 1], ["foot", "shin_and_lower_leg", "knee_and_nearby_areas",  "" ] );
		zones[ZONE_IX] = ZoneBody.create("to the Upper Legs", new < Number > [2, 3, 1], ["knee_and_nearby_areas", "thigh", "hip" ] );
		zones[ZONE_X] = ZoneBody.create("to the Pelvis", new < Number > [2, 2, 2], ["hip", "groin", "lower_abdomen" ] );  // NOTE: missing rules for female/male cases refer to core booklet
		zones[ZONE_XI] = ZoneBody.create("to the Belly", new < Number > [5, 1], ["lower_abdomen", "flesh_to_the_side" ] );
		zones[ZONE_XII] = ZoneBody.create("to the Chest", new < Number > [2,4], ["upper_abdomen", "chest" ] );
		zones[ZONE_XIII] = ZoneBody.create("to the Head", new < Number > [2, 2, 2], ["collar_and_throat", "face", "head" ] );
		zones[ZONE_XIV] = ZoneBody.create("to the Arm", new < Number > [1, 2, 1, 2], ["hand", "forearm", "elbow", "upper_arm" ] );
		
		// Blunt
		zones[ZONE_I] = ZoneBody.create("to the Lower Legs", new <Number>[1,3,2], ["foot", "shin_and_lower_leg", "knee_and_nearby_areas"] );
		zones[ZONE_II] = ZoneBody.create("to the Upper Legs", new < Number > [2, 3, 1], ["knee_and_nearby_areas", "thigh", "hip"] );
		zones[ZONE_III] = ZoneBody.create("for Horizontal Swing", new < Number > [1, 1, 1, 2, 1], ["hip", "upper_abdomen", "lower_abdomen", "ribcage", "arms"] );
		zones[ZONE_IV] = ZoneBody.create("for Overhand Swing", new < Number > [2, 1, 1, 1, 1], ["upper_arm_and_shoulder", "upper_body", "neck", "lower_head", "upper_head"] );
		zones[ZONE_V] = ZoneBody.create("for Downward Swing from Above", new < Number > [2, 1, 3], ["shoulder", "lower_head", "upper_head" ] );
		zones[ZONE_VI] = ZoneBody.create("for Upward Swing from Below", new < Number > [3, 1, 1, 1], ["inner_thigh", "groin", "abdomen", "lower_head" ] );
		zones[ZONE_VII] = ZoneBody.create("to the Arms", new < Number > [1, 2, 1, 2], ["hand", "forearm", "elbow", "upper_arm_and_shoulder" ] );
		// thrusts
		zones[ZONE_VIII] = ZoneBody.create("to the Lower Legs", new < Number > [1, 3, 1, 1], ["foot", "shin_and_lower_leg", "knee_and_nearby_areas",  "" ] );
		zones[ZONE_IX] = ZoneBody.create("to the Upper Legs", new < Number > [2, 3, 1], ["knee_and_nearby_areas", "thigh", "hip" ] );
		zones[ZONE_X] = ZoneBody.create("to the Pelvis", new < Number > [2, 2, 2], ["hip", "groin", "lower_abdomen" ] );  // NOTE: missing rules for female/male cases
		zones[ZONE_XI] = ZoneBody.create("to the Belly", new < Number > [6], ["lower_abdomen"] );
		zones[ZONE_XII] = ZoneBody.create("to the Chest", new < Number > [2,4], ["upper_abdomen", "chest" ] );
		zones[ZONE_XIII] = ZoneBody.create("to the Head", new < Number > [1, 1.5, 1.5, 2], ["neck", "face", "lower_head",  "upper_head" ] );
		zones[ZONE_XIV] = ZoneBody.create("to the Arm", new < Number > [1, 2, 1, 2], ["hand", "forearm", "elbow", "upper_arm_and_shoulder" ] );
		
	
		
		centerOfMass = CENTER_OF_MASS;
	
		//zones[ZONE_I] = new ZoneBody();
	}
	
}

class CharacterSheet {
	// attributes
	// 4 for average human
	
	public var name:String;
	
	public var strength:int;
	public var agility:int;
	public var toughness:int;
	public var endurance:int;
	public var health:int;
	
	public var willpower:int;
	public var wit:int;
	public var mentalapt:int;
	public var social:int;
	public var perception:int;
	
	// weapon and profeciicencies
	public var profeciencies:Object = { };  // object hash consisting of profeciencyId key and skill level value
	public var profeciencyIdCache:String;
	public var bodyType:BodyChar;
	
	public var weapon:Weapon;
	public var weaponOffhand:Weapon;
	
	public static const WOUND_TYPE_CUT:int = 1;
	public static const WOUND_TYPE_PIERCE:int = 2;
	public static const WOUND_TYPE_BLUNT_TRAUMA:int = 4;
	
	public var wounds:Object;  // object hash to keep track of wounds, their pain,bloodlost and shock... and wound types involved (uses a bitmask),  
	//   using part_id:{}     keyvalue pair  
	// A wound value object goes by  {  pain:?, BL:?, shock:?, woundTypes:? }   
	
	public function refreshDefaultProfs():void {
		var profReference:Object = cloneObj(profeciencies);
		for (var p:String in profReference) {
			var baseScore:int = profReference[p];
			var prof:Profeciency = ProfeciencySheet.getProfeciency(p);
			//if (prof == null) throw new Error("SHould not be!:"+p);
			if (prof == null) {
				 throw new Error("SHould not be!:"+p);
				//continue;  // excpetion due to incomplete list.
			}
			
			var defaults:Object = prof.defaults;
			for (var d:String in defaults) {
				if ( ProfeciencySheet.getProfeciency(d) == null) {
					continue;  // exception due to incomplete data entry
				}
				var defaultedScore:int = baseScore-defaults[d];
				var curCompareScore:int = profeciencies[d] != null ? profeciencies[d] : 0;
			
				if (defaultedScore > 6) defaultedScore = 6;
				if (defaultedScore > curCompareScore ) {
					profeciencies[d] = defaultedScore;
				}
			}
		}
		//throw new Error( JSON.stringify(profeciencies) );
	}
	
	
	public function clone():CharacterSheet {  
		var c:CharacterSheet = new CharacterSheet();
		c.name = name;
		c.strength = strength;
		c.agility = agility;
		c.toughness = toughness;
		c.endurance = endurance;
		c.health = health;
		
		c.willpower = willpower;
		c.wit = wit;
		c.mentalapt = mentalapt;
		c.social = social;
		c.perception = perception;
		
		c.profeciencies = cloneObj(profeciencies);

		c.weapon = weapon;
		c.weaponOffhand = weaponOffhand;
		c.profeciencyIdCache = profeciencyIdCache;
		
		c.bodyType = bodyType;
		c.wounds = wounds;
		
		return c;
	}
	
	private function cloneObj(obj:Object):Object {
		var o:Object = { };
		for (var p:String in obj) {
			o[p] = obj[p];
		}

		return o;
	}
	
	
	public function resetAllAttributes(val:int):void {
		strength = val;
		agility = val;
		toughness = val;
		endurance = val;
		health = val;
		
		willpower = val;
		wit = val;
		mentalapt = val;
		social = val;
		perception = val;
	}
	
	public function invalidateHandEquipment():void {
		profeciencyIdCache = null;
	}
	
	
	public function getReflex():int {
		return (agility + wit) / 2;
	}
	public function getAim():int {
		return (agility + perception) / 2;
	}
	public function getKnockdown():int {
		return (strength + agility) / 2;
	}
	public function getKnockout():int {
		return (toughness + (willpower / 2) );
	}
	public function getSpeed():Number {
		return (strength + agility + endurance) / 2;
	}
	
	
	public function getTotalBloodLost():int {
		return 0;
	}
	public function getCurrentHealth():int {
		return health - getTotalBloodLost();
	}
	
	public function getTotalPain():int {
		return 0;
	}
	
	private function pickBestProfeciency(weapProfs:Array):String {
		var highestScore:int = 0;
		var highestProf:String = "";
		
		for (var p:String in profeciencies) {
			for (var k:int = 0; k < weapProfs.length; k++) {
				var profId:String = weapProfs[k];
				if (profId == p) {
					
					if (profeciencies[profId] > highestScore) {
					
						highestScore = profeciencies[profId];
						highestProf = profId;
					}
				}
			}
		}
		//if (highestProf != "") throw new Error("A");
		return highestProf;
	}
	
	public function getMeleeProfeciencyId():String {
		// determine best profeciency to use for given set of weaponary
		profeciencyIdCache = "";
		//var hasShield:Boolean = false;
		
		if (weapon!=null) {
			//weapon.profeciencies.indexOf("");
			
			profeciencyIdCache = pickBestProfeciency(weapon.profeciencies);
		}
		else {
			if (weaponOffhand == null  || !weaponOffhand.shield) {
				profeciencyIdCache = "pugilism";
			}
		}
		if (weaponOffhand!=null) {
			//hasShield = weaponOffhand.shield;
		}
		return profeciencyIdCache;
	}
	
	public function getMeleeProfeciencyIdCached():String {
		return profeciencyIdCache != null ? profeciencyIdCache : getMeleeProfeciencyId();
	}
	
	
	public function getMeleeProfeciencyLevel():int {
		if (profeciencyIdCache == null) profeciencyIdCache = getMeleeProfeciencyId();
		
		return profeciencyIdCache !=  "" ? (profeciencies[profeciencyIdCache] != null ? profeciencies[profeciencyIdCache] : 0)  : 0;
	}
	
	public var cpDepletion:int = 0;
	
	public function getMeleeCombatPoolAmount(carryOverShock:int=0):int {
		return getMeleeProfeciencyLevel() + getReflex() - (cpDepletion=Math.max(getTotalPain(), carryOverShock)); 
	}
	
	/**
	 * Determines TN for given manuever of yours based off your character stats/equipment and enemy's manuever(if available), 
	 * and also checks if your manuever is valid/usable as well given those stats/equipment and enemy manuever situation.
	 * @param	manuever	The manuever to check
	 * @param	attacking	Is this an offesnive manuever? Or a defensive one?
	 * @param   enemyManuever  The manuever up are up against, if any, and implies that enemy is attacking. Thus, if you are defending against an enemy attack, this is required.
	 * @param   enemyDiceRolled How much dice the enemy is rolling against you in the given enemy manuever
	 * @param   enemyTargetZone  The target zone the enemy is aiming at in the given enemy manueveer
	 * @return	A valid TN (Target number). If target number is zero, it's assumed the manuever is unusable/invalid!
	 */
	public function getManueverTN(manuever:Manuever, attacking:Boolean, fight:FightState, enemyManuever:Manuever=null, enemyDiceRolled:int=0, enemyTargetZone:int=0):int {
		if (manuever.defaultTN != 0) {
			return manuever.defaultTN;
		}

		var useWeapon:Weapon;
		
		
		if (attacking) {  
			useWeapon = manuever.offHanded ? weaponOffhand : weapon;
			if (useWeapon == null) useWeapon = WeaponSheet.find("Punch");
			if ( manuever.attackTypes == Manuever.ATTACK_TYPE_STRIKE ) {
				return useWeapon.ATN;
			}
			else if (manuever.attackTypes == Manuever.ATTACK_TYPE_THRUST) {
				return useWeapon.ATN2;
			}
			else {   // can both perform a strikey and thrustey move
				// if damageType is zero neutral, than assumed no sharp thrusts are available, but can still spike bluntly
				if (manuever.damageType == 0) {
					if (useWeapon.blunt) {
						return useWeapon.ATN2 != 0 ? useWeapon.ATN2 :  useWeapon.ATN;  // consider spiking ATN, if any, otherwise use default ATN
					}
					else {  // cutting only for non-blunt weapons
						return useWeapon.ATN;
					}
				}
				else if (manuever.damageType == Manuever.DAMAGE_TYPE_PUNCTURING) {  // if puncturing, assumed thrusting ATN
					return useWeapon.ATN2;
				}
				else  {  // assumed Manuever.DAMAGE_TYPE_CUTTING as only option left
					return useWeapon.ATN;
				}
			}
			
		}
		else {
			
			useWeapon = manuever.isDefensiveOffHanded() ? weaponOffhand : weapon;
			if (useWeapon == null) useWeapon = WeaponSheet.find("Punch");
			
			if (manuever.manueverType == Manuever.MANUEVER_TYPE_MELEE) {
				return enemyDiceRolled <= 4 && Manuever.isThrustingMotion(enemyTargetZone)  ?  // LATER, post-emptive DTN cases
						(useWeapon.DTNt != 0 ? useWeapon.DTNt : useWeapon.DTN)  : useWeapon.DTN;
			}
			else return useWeapon.DTN2;
			
		}
	}
	
	public static function createBase(name:String, profeciencies:Object, bodyType:BodyChar, weapon:Weapon=null, weaponOffHand:Weapon=null, baseAttr:int = 5):CharacterSheet {
		var c:CharacterSheet = new CharacterSheet();
		c.name = name;
		c.wounds = { };
		c.profeciencies = profeciencies;
		c.weapon = weapon;
		c.weaponOffhand = weaponOffHand;
		c.resetAllAttributes(baseAttr);
		c.refreshDefaultProfs();
		return c;
	}
	
	
}

class FightState {
	
	// instance schedule 
	public var s:int = 0;  // the current step within the exchange
	public var e:Boolean = false;  // false for exchange 1/2, true for exchange 2/2
	public var side:int = 1;

	// rouguelike stuffz
	public static const SIDE_FRIEND:int = 0;
	public static const SIDE_ENEMY:int = 1;
	
	public static const FLAG_ENEMY_EAST:int = 1;
	public static const FLAG_ENEMY_WEST:int = 2;
	public static const FLAG_ENEMY_NORTH:int = 4;
	public static const FLAG_ENEMY_SOUTH:int = 8;
	
	public static const OFFSET_INITIATIVE:int = 4;
	
	public static const FLAG_INITIATIVE_EAST:int = 16;
	public static const FLAG_INITIATIVE_WEST:int = 32;
	public static const FLAG_INITIATIVE_NORTH:int = 64;
	public static const FLAG_INITIATIVE_SOUTH:int = 128;
	
	public static const FLAG_INITIATIVE_SYNCED:int = 256;
	public var flags:int = 0;
	
	public static const DIRECTIONS:Array =  [[1, 0], [ -1, 0], [0, 1], [0, -1]];
	public static var DIR_INDEX_LOOKUP:Vector.<int> = new <int>[
		//[[1, 0], [ -1, 0], [0, 1], [0, -1]]["rlbf"
		3,  	  //0 : 00   //  y is negative 
		1,      //1 : 01   //  x is negative 
		2,      //2 : 10   //  y is positive 
		0	 	  //3 : 11   // x is positive 
	];
	
	public static function getDirectionIndex(x:int, y:int):int {
		//if (x == 0 && y == 0) return -1;
		
		var bits:int = 0;
			bits |= x != 0 ?  1 : 0;
				bits |= x != 0 ?  (x > 0 ? 2 : 0)  :  (y > 0 ? 2 : 0); 
			return DIR_INDEX_LOOKUP[bits];
	}
	
	// by right, these position values shouldn't be here, duplicate stored values at given timestamp
	public var x:int;
	public var y:int;
	public var timestamp:uint = uint.MAX_VALUE;  // lol, unlikely to happen
	
	// riddle stuff here
	
	public var numEnemies:int = 0;
	public var initiative:Boolean = true;  // self initaitive main flag. 
	public var initiativeMask:uint = 0;  // currently not used, but useful to handle multi-initaitive situations later on
	public var paused:Boolean = true;
	
	// Declared manuevers info
	//public var manuever:int = -1;  // primary manuever index (declared move) for the current turn
	public var manuevers:Array = [ { manuever: -1, dice:0 } ]; // for composite/multiple manuevers within the stack
	public var enemyManuevers:Array = [];  // any detected enemy manuevers made against you...
	
	// The state of the fight
	public var rounds:int = 0;
	public var attacking:Boolean = false;  // flag to indicate whether is attacking on current turn roll
	public var bumping:Boolean = false;  // flag to keep track of fast track bump rolls for roguelike gamemode
	public var shortRangeAdvantage:Boolean = false;
	public var lastAttacking:Boolean = false; // flag to indicate if was attacking on last declared move
	public var combatPool:int;

	
	
	public function FightState() {
		
	}
	
	public static function pickDefaultManuever(charSheet:CharacterSheet, fightState:FightState, manueverEntry:Object,  defaultList:Array, gameObject:GameObject):void {
		
		var manueverCost:int = int.MAX_VALUE;
		var manueverTN:int = int.MAX_VALUE;
		var pickedManuever:Manuever;
		// simply pick manuever with lowest TN and lowest cost, and deals basic damage.
		var len:int = defaultList.length;
		for (var i:int = 0; i < len; i += 3) {
			var manuever:Manuever = defaultList[i];
			var cost:int =  defaultList[i + 1];
			var tn:int =    defaultList[i + 2];
			if (tn < manueverTN) {
				manueverCost = cost;
				pickedManuever = manuever;
				manueverTN = tn;
			}
			if (cost < manueverCost) {
				manueverCost = cost;
				pickedManuever = manuever;
				manueverTN = tn;
			}
		}
		if (pickedManuever == null) throw new Error("Could not find default manuever!");
		
		// targetZone:??, numDice:?,  tn:?,
		manueverEntry.manuever = pickedManuever;
		manueverEntry.tn = manueverTN;
		manueverEntry.numDice = int( (fightState.combatPool - manueverCost) / 2 );
		if (manueverEntry.numDice == 0) manueverEntry.numDice = 1;
		
		if (fightState.attacking) {
			var pickRandomTargetZone:int =   HumanoidBody.CENTER_OF_MASS[0]; // HumanoidBody.CENTER_OF_MASS[int(Math.random() * 2)]; // + Math.random() * 5 * Math.random();
			manueverEntry.targetZone =  pickRandomTargetZone; // TODO: pick targetzone based off character sheet's body refernece
		}
		// later: if !fight.attacking, ie. defending...avoid using the Full Evade manuever and Partial Evade, unless partial evade TN is lower
		
	}
	
	public static var AVAILABLE_MANUEVERS:Array = [];
	public function getListOfAvailableManuevers(charSheet:CharacterSheet, fight:FightState, ent:GameObject, enemyManuever:Manuever=null, enemyDiceRolled:int=0, enemyTargetZone:int=0 ):Array {
		var meleeProf:String = charSheet.getMeleeProfeciencyIdCached();
		var prof:Profeciency = ProfeciencySheet.getProfeciency(meleeProf);
		var costWithProf:Object = attacking ? prof.atkCosts : prof.defCosts;
		var mask:uint = attacking ? prof.offensiveManuevers : prof.defensiveManuevers;
		var list:Array = attacking ?  ManueverSheet.offensiveMelee : ManueverSheet.defensiveMelee;
	
		var len:uint = list.length;
		
	//	var traceList:Array = [];
		var filteredList:Array = AVAILABLE_MANUEVERS;  // a filtered list of Manuever and cost 3-tuple
		var count:int = 0;
		var traceMask:int = 0;
		
		for (var i:uint = 0; i < len; i++) {
			if (  (mask & (1 << i)) != 0 ) {
				var manuever:Manuever = list[i];
				

		
				var tn:int =  charSheet.getManueverTN(manuever, attacking, this, enemyManuever, enemyDiceRolled, enemyTargetZone);

				if (tn == 0) continue;  // unavailable move based off character sheet
				
				
				var cost:int;
				if (manuever.cost > 0) {
					cost = manuever.cost;
				}
				else {
					cost = costWithProf[manuever.id] != null ? costWithProf[manuever.id] is Array ? ProfeciencySheet.resolveProfManueverCostChoice(manuever.id, costWithProf[manuever.id], ent.components ) : costWithProf[manuever.id]   :   0;
				}
				// later: apply stance modifiers to manuever costs
				// todo: apply range penalties to manuever costs
				
				
				
				
				if (cost >= combatPool) {  // you can't afford it
					continue;
				}
				//traceList.push(manuever.name);
				filteredList[count++] = manuever;
				filteredList[count++] = cost;
				filteredList[count++] = tn;
			}
			
		}

		//throw new Error(traceList);
		
		if (!attacking) {  // add the 2 evasive manuevers, full evade is a situational choice (return 0 instead of >0)
		
			// also add buy initiative manuever at bottom
		}
		
		
		
		filteredList.length = count;
		return filteredList;
	}
	
	public function resetManuevers():void {
		manuevers[0].manuever = -1;
		manuevers[0].dice = 0;
		manuevers.length = 1;
		enemyManuevers.length = 0;
	}
	public function setManuever(val:int, numDice:int=0, at:uint = 0):void {
		if (at >= manuevers.length) throw new Error("out of range!:"+at + "/"+manuevers.length);
		manuevers[at].manuever = val;
	}
	public function appendManuever(val:int):void {
		manuevers.push( { manuever:val } );
	}
	
	public function resetRolls():void {
		attacking = false;
		bumping = false;
		resetManuevers();
	}
	
	public function resolvable():Boolean { 
		return  (s == 2);// && (e || rounds != 0) );
		
	}
	
	
	// this is handled after resolveAgainst(), and can involve refreshing of the combat pool if possible.
	public function resolve(man:GameObject):void {
		var charSheet:CharacterSheet = man.components.char;
		
		if ( resolvable() ) { 
			lastAttacking = attacking;
			
			
			// if valid fleeing situation, resolve it! Note ta resolveAgainst() can cancel out fleeing manuever==0
			if (!attacking && manuevers[0].manuever == 0 && man.moveArray != null && man.moveArray.length != 0 && (man.moveArray[0] !=0 || man.moveArray[1]!=0)) {
				
				if ( !man.dungeon.checkBumpable(man.mapX + man.moveArray[0], man.mapY + man.moveArray[1]) ) {
				//	throw new Error(
					// issue #1 to fix: fleeing must resolve first no matter what, but in the event there is no more path of retreat
					// at the time of rolling for defense, then regular menu appears but can still flee in given free other direction
					
					// issue #2 to fix , // find a way to execute a instanced walk procedure in given direction of 
					if (man.type === "man") {   // temp for testing, todo: allow AI as well to retreat
						reset(true);
						
						man.moving = true;  
						man.bumping = false;
						
						// synchronise direction wi
						//[[1, 0], [ -1, 0], [0, 1], [0, -1]]["rlbf"
						man.dir = GameObject.getDirection(man.moveArray[0], man.moveArray[1]);
				
						if( man.animState == "walk2" ){ man.action("walk1") }
						else{ man.action("walk2") }
							//man.dir = 
				
							man.dungeon.wait = GameObject.WAITKEY_STEP_NUM_FRAMES;
						
					}

					
				}
				
			}
			
		
			if (e) {
				UITros.TRACE("Refreshing combat pool for: " + man.dungeon.getNameWithDirToMan(man));
				refreshCombatPool(charSheet); 
				// refresh combat pool, because later in loop will step from e to !e
			}
			
		}
	}
	
	public function refreshCombatPool(charSheet:CharacterSheet):void {
		 combatPool =  charSheet.getMeleeCombatPoolAmount(combatPool < 0 ? -combatPool : 0);
	}
	
	public function clone():FightState {
		var fState:FightState = new FightState();
		fState.side = side;
		return fState;
	}
	
	public function step():void {
		
			s++;
			if (s >= 3) {
				s = 0;
				e = !e;
				s = 0;
				if (!e) rounds++;
			}
		
	}
	
	// static controller methods (later to re-factor out if necessary..)
	public static function getNeighbour(dungeon:Dungeon, x:int, y:int, directionIndex:int):FightState {
		
		var dir:Array = DIRECTIONS[directionIndex];
		var vec:Vector.<GameObject> = dungeon.checkComponent( x + dir[0], y + dir[1], "fight");
		return vec.length  ? vec[0].components.fight : null;
	}
	
	public static function updateSurroundingStates(dungeon:Dungeon, x:int, y:int, radius:int):void {
		var minx:int= x - radius;
		var miny:int= y - radius;
		var maxx:int= x + radius;
		var maxy:int = y * radius;
		minx = minx  >= 0 ? minx : 0;
		miny = miny  >= 0 ? miny : 0;
		var mapWidth:uint = dungeon.mapWidth;
		var mapHeight:uint = dungeon.mapHeight;
		maxy = maxy >= mapHeight  ? maxy - 1 : maxy;
		maxx = maxx >= mapWidth  ? maxx - 1 : maxx;
		var myStack:Array = [];
		
		  for(var i:uint = 0; i< mapWidth; i++ ){
            for (var j:uint = 0; j < mapHeight; j++ ) {
				var vec:Vector.<GameObject> = dungeon.checkComponent(i, j, "fight");
				var b:int = vec.length;
				while (--b > -1) {
					var gameObj:GameObject = vec[b];
					var fState:FightState = gameObj.components.fight;
					if (fState.timestamp != dungeon.timestamp) {
						fState.timestamp = dungeon.timestamp;
						var lastNumEnemies:int = fState.numEnemies;
						//if (fState.s < 2 ) {
						updateNeighborEnemyStates(gameObj, fState, dungeon);
						dungeon.fightStack.push(fState);
						//}
						
						if (lastNumEnemies == 0 && fState.numEnemies > 0) {
							//UITros.TRACE( "("+gameObj.dungeon.getNameWithDirToMan( gameObj) + " enters into a fight..)" );
							fState.refreshCombatPool(gameObj.components.char);
						}
						
						if (lastNumEnemies > 0) {
							if (  fState.numEnemies == 0 ) {
								fState.reset(true);
								
							}
							else {
								
								//	fState.step();
								myStack.push(fState);
								
							}
						}
						else if ( (fState.flags & FLAG_INITIATIVE_SYNCED) ) {
							myStack.push(fState);
							//throw new Error("TO STEP FORWARD SYNCED");
							
						}
						
							
						
					}
					
				}
			}
		  }
		  
		  var k:int = myStack.length; // dungeon.fightStack.length;
		  while (--k > -1) {
			  myStack[k].step();
		  }
		  
		  // for the sake of defering...bah!!
		  dungeon.clearFightStack();  // warning,,,backtrack code smell hack here
	}
	
	
	private static function updateNeighborEnemyStates(man:GameObject, manFight:FightState, dungeon:Dungeon):void  {
		var directions:Array = DIRECTIONS;  //["rlbf".indexOf(man.dir)];

		manFight.numEnemies = 0;
		manFight.flags = 0;
		var len:int = directions.length;
		manFight.x = man.mapX;
		manFight.y = man.mapY;

		for (var i:int = 0; i < len; i++) {
			//	manFight.flags |= ( 1 << (OFFSET_INITIATIVE + i) );
			var dir:Array = directions[i];
			var xi:int = dir[0];
			var yi:int = dir[1];
			xi += man.mapX;
			yi += man.mapY;
			if (xi >= 0 && xi < dungeon.mapWidth && yi >= 0 && yi < dungeon.mapHeight) {
				var fights:Vector.<GameObject> = dungeon.checkComponent(xi, yi, "fight");
				if (fights.length > 0) {  //!gotEnemy &&
					// assumed only stack 1 fighter at the moment. In grappling situations, can stack 2 fighters.
					var enemyFight:FightState =  fights[0].components.fight;
					//if (enemyFight.s == 2) continue;
					//if (man.type === "enemy" && fights[0].type==="man") throw new Error("A");
					if (manFight.hostileTowards( enemyFight ) ) {
					// whoever i bumped-rolled against 
				
					// apparently the below condition is causing problems... dunno why
					// enemyFight.s != manFight.s &&  /
						if ( manFight.withinExchangeWindow() && enemyFight.withinExchangeWindow() &&  (manFight.bumping||enemyFight.bumping)  && dungeon.containsObjAt( man.mapX + man.moveArray[0], man.mapY + man.moveArray[1], fights[0])  ) {
							//
							
							manFight.syncStepWith(enemyFight);
							manFight.flags |= FLAG_INITIATIVE_SYNCED;
							enemyFight.flags |= FLAG_INITIATIVE_SYNCED;
							//UITros.TRACE("Syncing step..");
							
							/*  // this doesn't occur
							if ( !(getNeighbour(dungeon, manFight.x, manFight.y, getDirectionIndex(man.moveArray[0], man.moveArray[1]) ).flags & FLAG_INITIATIVE_SYNCED) ) {
								UITros.TRACE("Exception2222..no sync match against target");
							}
							*/
							//if (man === man.dungeon.man) throw new Error("A");
							//throw new Error("A:"+manFight.firstExchangeWindow() + ", "+enemyFight.firstExchangeWindow() );
						}
						manFight.numEnemies++;
						manFight.flags |= (1 << i);  
						
					} 
				}
			}
			
		}
		
		//if (manFight.flags & FLAG_INITIATIVE_SYNCED) {
			
		//}
	}
	
	public static function updateNeighborInitiative(manFight:FightState, dungeon:Dungeon):void { 
		var directions:Array = DIRECTIONS;  
		var len:int = directions.length;
		//var man:GameObject =  dungeon.checkComponent(manFight.x, manFight.y, "fight")[0];
		
		if ((manFight.flags & FLAG_INITIATIVE_SYNCED) != 0) {
		//	UITros.TRACE("Already synced beforehand:" + (dungeon.man.components.fight === manFight));
			if ((dungeon.man.components.fight === manFight)) {
				var nFight:FightState = getNeighbour(dungeon, manFight.x, manFight.y, getDirectionIndex(dungeon.man.moveArray[0], dungeon.man.moveArray[1]) );
				if ( nFight &&  !(nFight.flags & FLAG_INITIATIVE_SYNCED) ) {
					UITros.TRACE("Exception..no sync match against target");
				}
			}
		}
		
		for (var i:int = 0; i < len; i++) {
		
			
			if (!(manFight.flags & (1 << i) )) continue;
			var dir:Array = directions[i];
			var xi:int = dir[0];
			var yi:int = dir[1];
			xi += manFight.x;
			yi += manFight.y;
			
			

			var fights:Vector.<GameObject> = dungeon.checkComponent(xi, yi, "fight");
			//if (fights.length > 0) {  //!gotEnemy &&
				// assumed only stack 1 fighter at the moment. In grappling situations, can stack 2 fighters.
				var enemyFight:FightState =  fights[0].components.fight;

				// Yep, this is allowed to happen below...
				// when an enemy moves in to engage somebody that is already locked in combat exchange and resolving rolls. 
				//if (!manFight.isSyncedWith(enemyFight)) {
					//throw new Error("Out of sync situation traced:"+ fights[0].type + ":" + enemyFight.getSchedule() + " | "+manFight.getSchedule());
				//}
				//if (manFight.bumping && 
				
					
				
				manFight.flags |= manFight.canRollAtkAgainst(enemyFight) ? ( 1 << (OFFSET_INITIATIVE+i)) : 0;
				manFight.flags |= manFight.isSyncedWith(enemyFight) ? FLAG_INITIATIVE_SYNCED : 0;
					
				
			//}
			
		}
		
		 // cancel step() action done earlier if required, becos when not synced with anyone, will always wait at schedule zero as if unengaged.
		 // so that can rejoin the fight sync at exchange 1, step 0 always..
		if ( !( (manFight.flags & FLAG_INITIATIVE_SYNCED) !=0) ) { 
			manFight.s = 0;
			manFight.e = false;
		//	if ( (manFight.flags & (1|2|4|8) )) UITros.TRACE("REsetting manFight scehdule:"+(dungeon.man.components.fight === manFight) );
		//	throw new Error("INvaliditing");
		}
	
	}
	
	private function getSchedule():Array 
	{
		return [s, e, timestamp, numEnemies];
	}
	
	public function setSideAggro(val:int):FightState {
		side = val;
		return this;
	}
	
	
	public function hostileTowards(fight:FightState):Boolean {
		return this.side != fight.side;
	}
	
	// this happens after a successful full disengagement, or during a battle exchange pause
	public function reset(disengaged:Boolean = false):FightState {
		// battle exchange pause
		s = 0;  
		e = false;
		initiative = true;
		attacking = false;
		lastAttacking = false;
		shortRangeAdvantage = false;
		paused = true;
		
		//manuever = -1;
		if (disengaged) {  // full disengagement
			numEnemies = 0;
			flags = 0;
			rounds = 0;
			bumping = false;
			resetManuevers();
		}
		return this;
	}
	
	public function syncStepWith(fight:FightState):void {
		if (fight.s >=  s) {  
			s = fight.s;
			//e = fight.e;
		}
		else {
			fight.s = s;
			
		}
		
	}
	
	public function canMove():Boolean {
		return s == 0;
	}
	
	public function aboutToRoll():Boolean {
		return s == 1;
	}
	public function isRolling():Boolean {
		return s == 2;
	}
	
	public function mustRollNow(fight:FightState = null):Boolean {
		//fight = null
		return fight!= null? getSyncStep(fight) == 1 : s==1;
	}
	
	private function getSyncStep(fight:FightState):int {
		return s >= fight.s ? s : fight.s;
	}
	
	public function isSyncedWith(fight:FightState):Boolean {
		return s == fight.s && e == fight.e;
	}
	
	public function firstExchangeWindow():Boolean {
		return  !e  && s < 2;
	}
	
	public function withinExchangeWindow():Boolean {
		return s < 2;
	}
	
	public function canRollDefAgainst(fight:FightState):Boolean {
		return s < 2 && fight.s < 2;
	}
	
	public function withinInitiativeScope(fight:FightState):Boolean {  // within initiative scope to roll attack if possible
		return ( isSyncedWith(fight) || (fight.firstExchangeWindow() && firstExchangeWindow()) );
	}
	public function withinRollableScope(fight:FightState):Boolean {  // whether within a rollable scope of either active defense or attack
		return ( fight.s==s || (fight.s < 2 && s < 2  ) );
	}
	
	public function canRollAtkAgainst(fight:FightState):Boolean {
		return initiative && withinInitiativeScope(fight);  //initiative  && 
	}
	
	public function canRollAttackAgainstDirection(dirIndex:int):Boolean {
		//dirIndex >=0 ? 
		return (flags & (1 << (OFFSET_INITIATIVE + dirIndex)) )  !=0;
	}
	
	public function notifyAttack(atkManuever:Object):void 
	{
		enemyManuevers.push(atkManuever);
	}
	
}

// End Riddle of Steel classes


//ゲームデータ用クラス
class Data {
    static public const cellSize:int=50,cellWidth:int=cellSize,cellHeight:int=cellSize;
    static public const gameWidth:int=465,gameHeight:int=465;
    static public const keyString:Object = {37:"←",38:"↑",39:"→",40:"↓",88:"x",90:"z",32:" "}
    
    //各オブジェクトに使うビットマップデータの設定
    public var MAP_SET:Object = { "man":"man0", "enemy":"enemy0", "room":"room0"}
    static public const URL:Object = {
        "man0":"http://assets.wonderfl.net/images/related_images/7/7a/7ab2/7ab26a6103d0b93fb53b431d9f9a241c84ce73d1",
        "room0":"http://assets.wonderfl.net/images/related_images/5/5f/5fcb/5fcbda915901271b3e1f41b64477a8556b55824e",
        "enemy0":"http://assets.wonderfl.net/images/related_images/f/fb/fb74/fb74951b6511ced8e7659452228703af0d991662"        
    }
    static public const URL_NAME:Array = ["man0","room0","enemy0"];
    static public const IMG_NAME:Object = {
        "man":["lw0","lw1","rw0","rw1","fw0","fw1","bw0","bw1", "ls" ,"rs" ,"fs" ,"bs" ,"lk" ,"rk" ,"fk" ,"bk" ,"lj" ,"rj" ,"fj" ,"bj" ,"ld" ,"rd" ,"fd" ,"bd" ],
        "room":["wall","road","stair","stone","room"],
        "enemy":["1lw0","1lw1","1rw0","1rw1","1fw0","1fw1","1bw0","1bw1"]
    }
    
    static public const OBJECT:Object = {
        "man": { type:"man", state:"w0", visual:"stand",  func: { key:Man.key }, components: { 
			char:CharacterSheet.createBase("Player", { "rapier":9, "swordshield":6 }, HumanoidBody.getInstance(), WeaponSheet.find("Rapier"), null, 5),
		fight:new FightState().setSideAggro(FightState.SIDE_FRIEND) }, 
		ability:{ map:false,block:true }, anim:Man.anim, animState:"walk1", dir:"f" },
        "enemy": { type:"enemy", state:"w0", num:"1", func: { key:Enemy.key },  visual:"stand", components: {
			char:CharacterSheet.createBase("Enemy", { "swordshield":5  }, HumanoidBody.getInstance(),  WeaponSheet.find("Gladius"), null, 5),
			fight:new FightState().setSideAggro(FightState.SIDE_ENEMY) }, 
			ability:{ map:false,block:true }, anim:Enemy.anim, animState:"walk", dir:"f" },
        "item": { func: { pick:null }, ability:{ map:false,block:true } },
        "fwall": { type:"room", state:"wall", visual:"front" },
        "bwall": { type:"room", state:"wall", visual:"back" },
        "rwall": { type:"room", state:"wall", visual:"right" },
        "lwall": { type:"room", state:"wall", visual:"left" },
        "ceil": { type:"room", state:"stone", visual:"ceil", ability:{ block:true } },
        "road": { type:"room", state:"road", visual:"floor", ability:{map:false} },
        "stair": { type:"room", state:"stair", visual:"floor" , ability: { map:false,stair:true,room:true }},
        "room": { type:"room", state:"room", visual:"floor", ability: { map:false,room:true } }
    }
    
    public static var FLOOR:Array = [　//各階の構造に関するデータ
        {//0階(デフォルト値）
            enMax:2, enMin:1,    //敵の数
            itMax:2, itMin:0,    //アイテムの数
            width:35, height:35,
            roomWidth:6, roomHeight:6,
            type:"random"
        },
        /* 1階 */{ enemy:[1], item:[] }
    ];
    public static var ENEMY:Object = [//敵のデータ
        /*デフォ*/{ name:"敵" },
        { name:"もさもさ",  life:60, walkType:"room" },
        { name:"ふさふさ", life:50, walkType:" random" }
    ]
    
    
    
    
    
    //ビットマップを記録したオブジェクト。ロード後に使用可能
    public var imageMap:Object = {};
    public var imageCell:Object = {};
    public var imageRect:Object = {};
    private var loaders:Vector.<Loader> = new Vector.<Loader>();
    
    
    //画像をロード。ローダーの配列を作る。
    public function load():Vector.<Loader>{
        for each(var url:String in URL){
            var loader:Loader = new Loader(); 
            loaders.push(loader);
        }
        loaders[0].load(new URLRequest(URL[URL_NAME[0]]), new LoaderContext(true));
        loaders[0].contentLoaderInfo.addEventListener("complete",onLoad,false,1000);
        return loaders;
    }
    //bitmapdataに画像を描画する
    public function draw(target:BitmapData,type:String,name:String,x:int=0,y:int=0,dir:Boolean=true):void{
        var map:String = MAP_SET[type];
        var mtr:Matrix = new Matrix(-1,0,0,1,x+cellWidth,y)
        if (dir) { mtr.a = 1, mtr.tx = x }
        if(-1 < IMG_NAME[type].indexOf(name)){
            target.fillRect( target.rect, 0 )
            target.draw( imageCell[map][ IMG_NAME[type].indexOf(name) ] ,mtr)
        }
    }
    public function getImage(type:String,name:String):BitmapData{ return imageCell[ MAP_SET[type] ][ IMG_NAME[type].indexOf(name) ].clone(); } 
    
    //指定した条件の物体を設置する。
    static public function setObject( dun:Dungeon,x:int,y:int,name:String ):GameObject{
        if(name != null && OBJECT[name] != null){
            var obj:Object = clone( OBJECT[name] );         
            var g:GameObject = new GameObject();
            for (var str:String in obj) { 
					g[ str ] = obj[ str ]; 
				}
			for (str in g.components) {
				g.components[str] = g.components[str].clone();  // currently using clone as factory method
			}
            g.mapX = x; g.mapY = y; g.x = (x - 0.5)* cellWidth;  g.y = (y - 0.5) * cellHeight;
            g.name = name; g.dungeon = dun;
        }
        dun.map[x][y].push( g );
        return g;
    }
    
    //マップを立体化する
    static public function stand( dun:Dungeon ):void {
        dun.view.scene = null;
        var scene:Scene3D = new Scene3D();
        for ( var i:int = 0; i < dun.map.length; i++ ) {
            for ( var j:int = 0; j < dun.map[i].length; j++ ) {
                for each( var g:GameObject in dun.map[i][j] ) {
                    if( g != null ){
                        g.bitmapData = dun.data.getImage( g.type, g.num + g.dir + g.state );
                        var material:BitmapMaterial = new BitmapMaterial( g.bitmapData );
                        g.plane = new Plane( material );
                        g.plane.scaleX = cellSize/g.bitmapData.width; g.plane.scaleY = cellSize/g.bitmapData.height;
                        g.plane.visible = false;
                        material.doubleSided = true;
                        setPlane(g);
                        if( g.name == "man" ){dun.man = g}
                        scene.addChild( g.plane );
                    }
                }
            }
        }
        dun.view.scene = scene;
    }
    static public function setPlane(g:GameObject):void{
        switch( g.visual ){
            case "ceil":     g.plane.z = -cellSize;
            case "floor":    g.plane.x = g.x; g.plane.y = g.y; break;
            case "stand":    g.plane.scaleX = g.plane.scaleY = 2;g.plane.z = -cellSize/2; g.plane.x=g.x;g.plane.y=g.y+5;g.plane.rotationX=-35; break;
            case "left":     g.plane.z = -cellSize/2; g.plane.x=g.x-25;g.plane.y=g.y;g.plane.rotationX=90;g.plane.rotationZ=270; break;
            case "right":    g.plane.z = -cellSize/2; g.plane.x=g.x+25;g.plane.y=g.y;g.plane.rotationX=90;g.plane.rotationZ=90; break;
            case "front":    g.plane.z = -cellSize/2; g.plane.x=g.x;g.plane.y=g.y+25;g.plane.rotationX=90;g.plane.rotationZ=180; break;
            case "back":     g.plane.z = -cellSize/2; g.plane.x=g.x;g.plane.y=g.y-25;g.plane.rotationX=90; break;
        }
    }
    
    static private var loadNum:int = 0;
    private function onLoad(e:Event):void{
        e.currentTarget.removeEventListener("complete",onLoad);
        var rect:Rectangle = e.currentTarget.content.getRect(e.currentTarget.content);
        imageMap[URL_NAME[loadNum]]=new BitmapData(rect.width,rect.height,true,0x000000);
        imageMap[URL_NAME[loadNum]].draw( e.currentTarget.content );
        imageMap[URL_NAME[loadNum]].lock();
        setImageRect(URL_NAME[loadNum]);
        loadNum++;
        if(URL_NAME.length>loadNum){
            loaders[loadNum].load(new URLRequest(URL[URL_NAME[loadNum]]), new LoaderContext(true));
            loaders[loadNum].contentLoaderInfo.addEventListener("complete",onLoad,false,1000);
        }
    }
    
    private function setImageRect(name:String):void{
        imageCell[name] = [];
        var map:BitmapData = imageMap[name];
        var lineColor:uint = map.getPixel32(map.width-1,map.height-1);
        var x:int = 0; var y:int=0; var height:int=0; var width:int=0; var count:int=0;
        while(true){
            width=0;height=0;
            if(lineColor != map.getPixel32(x,y) ){
                for(var i:int=1;i+x<map.width;i++){
                    if( lineColor == map.getPixel32(x+i,y) ){break;}
                }
                width=i;
                for(var j:int=1;j+y<map.width;j++){
                    if( lineColor == map.getPixel32(x,y+j) ){break;}
                }
                height=j;
                var rect:Rectangle = new Rectangle(x,y,width,height);
                var rect2:Rectangle = new Rectangle(0,0,width,height);
                var cell:BitmapData = new BitmapData(rect.width,rect.height,true,0x0)
                cell.setVector( rect2,map.getVector( rect ) );
                imageCell[name].push( cell );
            }
            x+=width+1;
            if(x>=map.width){ y+=height+1;x=0; }
            if(y>=map.height){ break; }
            count++;
        }
    }
    
    //ランダムマップ生成
    static public function makeMap( dun:Dungeon, flr:int ):void {
        var count:int = 0; 
        while(true){ 
            count++;
            var data:Object = clone(　FLOOR[ ((flr-1) % (FLOOR.length-1))+1 ]　);
            for ( var str:String in FLOOR[0] ) {
                if( data[str] == null ){ data[str] = FLOOR[0][str] }
            }
            //まっさらなマップ生成
            dun.mapWidth = data.width; dun.mapHeight = data.height;
            dun.map = new Vector.<Vector.<Array>>();
            for ( var i:int = 0; i < dun.mapHeight; i++ ) {
                dun.map[i] = new Vector.<Array>(); 
                for ( var j:int = 0; j < dun.mapWidth; j++ ){ dun.map[i][j] = [];  }
                dun.map[i].fixed = true;
            }
            dun.map.fixed = true;
            dun.rooms = new Vector.<Rectangle>();
            
            if ( data["type"] == "random" ) {
                //マップに部屋を配置
                var missCount:int = 0; 
                while(　missCount < 10 /*&& map.rooms.length > 1*/ ){
                    if ( MapUtil.requestRoom( dun, data ) == false ) { missCount++; }
                    else{ missCount=0; }
                }
                /*通路を設置*/ if( MapUtil.makeRoad( dun ) == false ){ continue; }
                /*壁配置*/    MapUtil.makeWall( dun );
                /*天井配置*/  MapUtil.makeCeil( dun );
                /*人配置*/    MapUtil.roomAdd( dun, dun.rooms[0], "man" );
                /*階段配置*/  MapUtil.roomSet( dun, dun.rooms[dun.rooms.length-1], "stair" );
                /*敵配置*/   MapUtil.addEnemy( dun, data );
            }
            break;
        }
    }
    
}

//マップ生成の補助をする関数をおさめたクラス
class MapUtil {
    static public function requestRoom( dun:Dungeon, d:Object ):Boolean {
        var rect:Rectangle = new Rectangle( Math.floor( Math.random() * (d.width - d.roomWidth - 2) ), Math.floor( Math.random() * (d.height - d.roomHeight - 2) ), d.roomWidth+2, d.roomHeight+2 );
        for each( var r:Rectangle in dun.rooms) { if ( r.intersects( rect ) ) { return false; } }
        rect.x++; rect.y++; rect.width -= 2; rect.height -= 2; 
        makeRoom( dun, rect );
        return true;
    }
    static private function makeRoom( dun:Dungeon, rect:Rectangle ):void {
        for (var i:int = 0; i < rect.width; i++ ) { for (var j:int = 0; j < rect.height; j++ ) {           
                var o:GameObject = Data.setObject( dun, rect.x+i, rect.y+j, "room" );
                o.param = { roomNum:dun.rooms.length }
        } }
        dun.rooms.push( rect );
    }
    static public function makeCeil( dun:Dungeon ):void { //マップ何もない所にceilを配置
        for (var i:int = 0; i < dun.mapWidth; i++ ) { for (var j:int = 0; j < dun.mapHeight; j++ ) {
                if (dun.map[i][j].length == 0) { Data.setObject( dun, i, j, "ceil" ); }
        } }
    }
    static public function makeWall( dun:Dungeon ):void {
        var o:GameObject;
        for (var i:int = 1; i < dun.mapWidth-1; i++ ) {
            for (var j:int = 1; j < dun.mapHeight-1; j++ ) {
                if (dun.map[i][j].length > 0) {
                    if( dun.map[i-1][j].length == 0 ){ Data.setObject( dun, i, j, "lwall" ); } 
                    if( dun.map[i+1][j].length == 0 ){ Data.setObject( dun, i, j, "rwall" ); } 
                    if( dun.map[i][j+1].length == 0 ){ Data.setObject( dun, i, j, "fwall" ); } 
                    //if( dun.map[i][j-1].length == 0 ){ Data.setObject( dun, i, j, "bwall" ); } 
                }
            }
        }
    }
    static public function makeRoad( dun:Dungeon ):Boolean {
        var roomConect:Array = [];var roomDir:Array = [];var count:int = 0;
        for(var n:int = 0; n < dun.rooms.length ; n++ ){ roomConect[n] = [n] }
        var roads:Vector.<Vector.<GameObject>> = new Vector.<Vector.<GameObject>>();
        var d:Array = [ [1,0],[-1,0],[0,1],[0,-1] ]; 
        for( var i:int; i<dun.rooms.length ;i++ ){ roomDir[i] = [ d[0], d[1], d[2], d[3] ] }
        while( count++ < 100 ){
            var roomNum:int = Math.random() * dun.rooms.length;
            if( roomDir[roomNum].length > 0 ){ var dir:Array = roomDir[roomNum].splice(Math.floor(Math.random()*roomDir[roomNum].length),1)[0] ;
            }else{ continue; }
            var road:Vector.<GameObject> = new Vector.<GameObject>();
            var room:Rectangle = dun.rooms[ roomNum ];
            var pos:Array = [ int(room.x+1 + (room.width-2)*Math.random()), int(room.y+1 + (room.height-2)*Math.random()) ]; 
            do{
                pos[0] += dir[0]; pos[1]+=dir[1];
                if( !room.contains(pos[0],pos[1]) ){
                    if( dun.check( pos[0], pos[1] ).length > 0 || dun.check( pos[0]+dir[1], pos[1]+dir[0] ).length > 0 || dun.check( pos[0]-dir[1], pos[1]-dir[0] ).length > 0  ){ break; }
                    if( dun.check( pos[0] + dir[0], pos[1] + dir[1] ).length > 0  ){
                        if( dun.check( pos[0]+dir[0]+dir[1], pos[1]+dir[0]+dir[1] ).length > 0 && dun.check( pos[0]-dir[1]+dir[0], pos[1]-dir[0]+dir[1] ).length > 0  ){
                             var target:GameObject = dun.check( pos[0] + dir[0], pos[1] + dir[1] )[0]
                             var rev:Array = d[ [ d[1],d[0],d[3],d[2] ].indexOf( dir ) ] ;
                             var c:int = target.param.roomNum;
                             if( target.name == "room"  &&  roomDir.indexOf( rev ) < 0 ) { break; }                      
                             else{   
                                if( roomConect[roomNum].indexOf(c) < 0 ){
                                    roomConect[roomNum].push(c);
                                    roomConect[c] = roomConect[roomNum];
                                }
                            }
                        }else{ break; }
                    } 
                    var o:GameObject = Data.setObject( dun, pos[0], pos[1], "road" ) 
                    o.param = { roomNum:roomNum, roadNum:count }
                    road.push( o );
                }
            }while( 1 < pos[0] && pos[0] < dun.map.length-2 && 1 < pos[1] && pos[1] < dun.map[0].length-2 )
            roads.push(road);
            if( roomConect[0].length == roomConect.length  ){
                for each( road in roads ){
                    for( var j:int = road.length-1; j>=0; j-- ){
                        var x:int = road[j].mapX; var y:int = road[j].mapY;
                        if( dun.check( x+1,y ).length + dun.check( x-1,y ).length + dun.check( x,y+1 ).length + dun.check( x,y-1 ).length == 1 ){
                            dun.map[x][y] = [];
                        }else{ j = 0 }
                    }
                }
                return true;
            }
        }
        return false;
    }
    static public function roomAdd( dun:Dungeon, room:Rectangle, str:String ):GameObject{ 
        while(true){
            var x:int = Math.floor(room.x+Math.random()*(room.width-2)+1);
            var y:int = Math.floor(room.y+Math.random()*(room.height-2)+1);
            if( dun.check(x,y,"block").length == 0 ){ break; }
        }
        return Data.setObject( dun, x, y, str );
    }
    static public function roomSet( dun:Dungeon, room:Rectangle, str:String ):GameObject{
        var x:int = Math.floor(room.x+Math.random()*(room.width-2)+1);
        var y:int = Math.floor(room.y+Math.random()*(room.height-2)+1);
        dun.map[x][y]=[]; 
        return Data.setObject( dun, x, y, str );
    }
    static public function addEnemy( dun:Dungeon, d:Object  ):void{
        for(var i:int=1;i < dun.rooms.length;i++){
            var l:int = Math.random()*(d.enMax-d.enMin+1) + d.enMin;
            for(var j:int=0;j < l;j++){
                var o:GameObject = roomAdd( dun, dun.rooms[i], "enemy" );
                var rand:int = d.enemy[ int(d.enemy.length*Math.random()) ];
                var data:Object = clone(　Data.ENEMY[rand] );
                for ( var str:String in Data.ENEMY[0] ) { if( data[str] == null ){ data[str] = Data.ENEMY[0][str] } }
                o.param = data;
            }
        }
    }
    static public function mapBitmap( dun:Dungeon ):BitmapData {
        return new BitmapData( dun.map.length, dun.map[0].length, true, 0 );
    }
    static public function mapDraw( dun:Dungeon ):void {
        var b:BitmapData = dun.mapBitmap.bitmapData;
        b.lock();
        var target:Vector.<GameObject>,see:int = 5;
        for(var i:uint = 0; i< dun.map.length; i++ ){
            for(var j:uint = 0; j< dun.map[0].length; j++ ){
                if( (target = dun.check(i,j,"map")).length > 0 ){
                    if( target[0].ability.map ){
                        if( target[0].name == "room" || target[0].name == "road" ){ b.setPixel32( i,j,0xFF00FF00 );
                        }else if( target[0].name == "stair" ){ b.setPixel32( i,j,0xFFFF0000 ) }
                        if( dun.man.mapX-see < i && i < dun.man.mapX+see && dun.man.mapY-see < j && j < dun.man.mapY+see ){            
                            for( var k:uint = 1; k<target.length; k++ ){
                                if( target[k].name == "enemy" ){ b.setPixel32( i,j,0xFF3344FF ) }
                                else if( target[k].name == "man" ){ b.setPixel32( i,j,0xFFFF00FF ) }
                                else if( target[k].name == "item" ){ b.setPixel32( i,j,0xFFFFFF00 ) }
                            }
                        }
                    }else{ b.setPixel32( i,j,0x000000FF ); }
                }
            }
        }
        b.unlock();
    }
    static public function mapUpdate( dun:Dungeon ):void {
        var target:Vector.<GameObject>  = dun.check(dun.man.mapX,dun.man.mapY,"map");
        if( target[0].ability.map == false ){ 
            target[0].ability.map = true
            if( target[0].name == "room" ){
                var rect:Rectangle = dun.rooms[ target[0].param.roomNum ];
                for (var i:uint = 0; i < rect.width; i++ ) { for (var j:uint = 0; j < rect.height; j++ ) {           
                      dun.check(i+rect.x,j+rect.y,"map")[0].ability.map = true;
                } }
            }
        }
    }
}


import frocessing.color.ColorHSV;
class EffectMap extends Bitmap{
    public var color:ColorHSV = new ColorHSV();
    public var back:BitmapData;
    public var moving:Boolean = true;
    function EffectMap(w:int,h:int){
        super( new BitmapData(w,h,true,0) );
        back = sphere( w,h );
        color.h = 0; color.s = 0; color.v = 1; color.a = 0;
    }
    
    public function onFrame(e:Event=null):void{
        var b:BitmapData = bitmapData;
        b.lock();
        b.fillRect( b.rect, color.value32 );
        b.draw( back );
        b.unlock();
    }
    private function sphere(w:int,h:int):BitmapData{
        var b:BitmapData = new BitmapData(w,h,true,0);
        b.lock();
        for( var i:int=0; i<w; i++ ){ for( var j:int=0; j<h; j++ ){
                var cx:int = i-(w>>1), cy:int = j-(h>>1);
                var r:int = 0x200 * Math.sqrt(cx*cx+cy*cy)/w - 0x40;
                r = r < 0xF0 ? r : 0xF0; r = r > 0 ? r : 0;
                b.setPixel32(i,j, 0x1000000 * r );
        } } 
        b.unlock();
        return b;
    }
}


//ロード画面
class NowLoading extends Sprite{
    static public const COMPLETE:String = "complete";
    public var loaders:Vector.<Object> = new Vector.<Object>;
    public var bytesTotal:uint=0,bytesLoaded:uint=0;
    private var _loaderNum:uint=0,_completedNum:uint=0,_openNum:uint=0; //ローダーの数
    private var text:Bitmap, sprite:ProgressSprite;
    private var onLoaded:Function;
    private var LETTER:Object = {
        "1":[[0,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"2":[[1,1,1],[0,0,1],[0,1,1],[1,0,0],[1,1,1]],"3":[[1,1,1],[0,0,1],[1,1,1],[0,0,1],[1,1,1]],"4":[[1,0,1],[1,0,1],[1,0,1],[1,1,1],[0,0,1]],"5":[[1,1,1],[1,0,0],[1,1,1],[0,0,1],[1,1,1]],
        "6":[[1,1,1],[1,0,0],[1,1,1],[1,0,1],[1,1,1]],"7":[[1,1,1],[0,0,1],[0,0,1],[0,0,1],[0,0,1]],"8":[[1,1,1],[1,0,1],[1,1,1],[1,0,1],[1,1,1]],"9":[[1,1,1],[1,0,1],[1,1,1],[0,0,1],[0,0,1]],"0":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],
        ".":[[0],[0],[0],[0],[1]]," ":[[0],[0],[0],[0],[0]],"n":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,0,1]],"w":[[0,0,0,0,0],[0,0,0,0,0],[1,0,1,0,1],[1,0,1,0,1],[1,1,1,1,1]],"o":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1]],
        "a":[[0,0,0],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"l":[[1],[1],[1],[1],[1]],"i":[[1],[0],[1],[1],[1]],"d":[[0,0,1],[0,0,1],[1,1,1],[1,0,1],[1,1,1]],"g":[[0,0,0],[0,0,0],[1,1,1],[1,0,1],[1,1,1],[0,0,1],[1,1,1]],
        "C":[[1,1,1],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"O":[[1,1,1],[1,0,1],[1,0,1],[1,0,1],[1,1,1]],"M":[[1,1,1,1,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1],[1,0,1,0,1]],"P":[[1,1,1],[1,0,1],[1,1,1],[1,0,0],[1,0,0]],
        "T":[[1,1,1],[0,1,0],[0,1,0],[0,1,0],[0,1,0]],"L":[[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],"E":[[1,1,1],[1,0,0],[1,1,1],[1,0,0],[1,1,1]]
    }
    //ステージと関数を渡す
    public function NowLoading(stage:Stage, onLoaded:Function = null){
        if(onLoaded == null){ this.onLoaded=nullFunc }else{ this.onLoaded=onLoaded }
        sprite = new ProgressSprite(stage.stageWidth,stage.stageHeight);
        text = new Bitmap( new BitmapData(30*4,8,true,0x00000000 ) ); 
        stage.addChild(this); addChild(sprite); addChild(text);
        with(text){scaleX=scaleY=1; blendMode="invert"; x=stage.stageWidth-text.width; y=stage.stageHeight-text.height;}
    }
    //ローダーの追加
    public function addLoader(loader:Loader):Loader{ setListener(loader.contentLoaderInfo);_loaderNum++;return loader;}
    public function addURLLoader(loader:URLLoader):URLLoader{setListener(loader); _loaderNum++; return loader;}
    
    
    private function nullFunc():void{}
    private function setListener(loader:*):void{
        loader.addEventListener("open", onOpen);
        loader.addEventListener("complete", onComplete);
        loader.addEventListener("progress", update);
    }
    private function update(e:Event=null):void{
        bytesLoaded=0; bytesTotal=0;
        for each(var loadObj:Object in loaders){
            bytesLoaded += loadObj.bytesLoaded;
            bytesTotal += loadObj.bytesTotal;
        };
        sprite.progress(bytesLoaded/bytesTotal * _openNum/_loaderNum);
        if(bytesTotal!=0){ setText( "now loading... "+(bytesLoaded/bytesTotal* _openNum/_loaderNum*100).toFixed(1) ); }
    }
    private function onOpen(e:Event):void{ _openNum++;loaders.push(e.currentTarget); bytesTotal+=e.currentTarget.bytesTotal; }
    private function onComplete(e:Event):void{ _completedNum++;if(_loaderNum == _completedNum){ setText( "COMPLETE" );onLoaded(); } }
    private function setText(str:String):void{
        var b:BitmapData = text.bitmapData; var l:int = str.length; var position:int = b.width;
        b.lock();b.fillRect(b.rect,0x000000);
        for(var i:int=0;i<l;i++){
            var letterData:Array = LETTER[str.substr(l-i-1,1)];position-=letterData[0].length+1;
            for(var n:int=0;n<letterData.length;n++){ for(var m:int=0;m<letterData[n].length;m++){ 
                if(letterData[n][m]==1){b.setPixel32(m+position,n+1,0xFF000000);} 
            } }
        }
        b.unlock();
    }
}
//このスプライトを編集することでロード画面を変えることができる。
class ProgressSprite extends Sprite{
    private var mapData:BitmapData,sphereData:BitmapData,noizeData:BitmapData;
    private var bfRate:Number=0; //前の段階での進行度
    private var drawRate:Number=0;
    private var maxLevel:int = 5; 
    private var meter:Array = new Array();
    
    //コンストラクタ
    public function ProgressSprite(width:int,height:int):void{
        mapData = new BitmapData(width,height,true,0x00000000); 
        addChild(new Bitmap(mapData)).blendMode="invert";
        for(var i:int=0;i<maxLevel;i++){
            meter[i]=0;
        }
        addEventListener("enterFrame",onFrame);
    }
    //ロードが進行したときに呼び出される。 rateはロードの進行度で0-1
    public function progress(rate:Number):void{ bfRate = rate; }
    private function draw(rate:Number, level:int=0):void{
        var thick:int = mapData.height*(0.61803)/1.61803;
        var floor:int = 0;
        for(var i:int=1;i<level+1;i++){
            thick*=(0.61803)/1.61803;
            floor+=thick;
        }
        mapData.fillRect( new Rectangle(0,mapData.height-floor,mapData.width*rate,thick), 0x1000000*int(0xFF*(maxLevel-level+1)/(maxLevel)));
    }
    private function onFrame(e:Event):void{
        for(var i:int=0;i<maxLevel;i++){
            var n:int = Math.pow(2,i+2);
            meter[i]=(bfRate+ meter[i]*(n-1))/n;
            draw(meter[i],i);
        }
    }  
}

//SiON
import org.si.sion.*;
import org.si.sound.*;
class MyDriver extends SiONDriver {
    public var dm:DrumMachine = new DrumMachine(0, 0, 0, 1, 1, 1);
    public var fill:SiONData;
    function MyDriver():void{
        super(); 
        volume = 2.0
        dm.volume = 0.1;
        setVoice(0, new SiONVoice(5, 2, 63, 63, -10, 0, 2, 20));
		
        fill = compile("#A=c&ccrccrc&cccrc&c&c&c;#B=<c&c>bragrf&fedrc&c&c&c;#C=<c&c>bragra&ab<crc&c&c&c>;%1@8,l16B;#D=rrrrrrrrrrrrcerg;#E=<c>bagfedcfedrc&c&c&c;#F=cdefgab<c>fgar<c&c&c&c>;");
		
        setSamplerData(0, render("%2@4 v8 l24 c<<c"));
        setSamplerData(1, render("%2@4 l60 ccc"));
        setSamplerData(2, render("%3@8 l12 <<<<<a0b0c0b0e0d0g"));
        setSamplerData(3, render("%3@4 l60 <<<<<c>c"));
        setSamplerData(4, render("%2@60 v2 l48 c<c"));
        setSamplerData(5, render("%3@0q0,c"));
        setSamplerData(6, render("%2@4, l24q0 <<c<<c>>c<<c>>"));
      //  play() ;
		
    }
}
class Sound{
    static public var driver:MyDriver = new MyDriver();
    static public function se(i:int,delay:int=0):void{
        driver.playSound(i,0,delay);
    }
    static public function music(i:int=1):void{
        switch(i) {
            case 1:
                //driver.dm.play();
                driver.dm.fadeIn(6);
                break;
            case 2:
                driver.dm.stop();
                driver.sequenceOn(driver.fill);
                break;
        }
    }
}

//配列の複製を返す
import flash.utils.getQualifiedClassName;
function clone(arg:*):*{
    var cl:*;
    var name:String = getQualifiedClassName(arg);
    if( name == "Object" || name == "Array" || name == "Vector" ){
        if( name == "Object" ){ cl = {}; }
        else if( name == "Array" ){ cl = []; }
        else if( name == "Vector" ){ cl = Vector([]); }
        for( var s:String in arg ){
            cl[s] = clone( arg[s] );
        }
        return cl;
    }else if( arg is Object && arg.hasOwnProperty("clone") && arg.clone is Function ){
        return arg.clone();
    }
    return arg;
}