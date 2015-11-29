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
import com.bit101.components.VBox;
import flash.events.Event;
import flash.events.MouseEvent;
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
	public static const STR_FULL_EVADE:String = "flee";  // attempt to move into a safe square to escape 
	public static const STR_AIM:String = "atk";   // you are currently aiming at the enemy prior to resolving the attack manuever
	public static const STR_TURN:String = "turn";  // turn to face given direction
	public static const STR_TARG:String = "targ";  // turn to consider target
	public static const STR_DEFEND:String = "Def";  // this will resolve the defense manuever
	public static const DELIBERATE_DEFEND_SUFFIX:String = "!";  // you  deliberate chose to roll defend. appended at the end of "def" or "Def" accordingly.
	
	public static const STR_DONE:String = "Okay";
	
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
		
		
		arrowRight.visible = !(wallMask & 1);
		arrowLeft.visible = !(wallMask & 2);
		arrowUp.visible = !(wallMask & 4);
		arrowDown.visible = !(wallMask & 8);
		
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
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_WEST) {
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 1))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowLeft.label = manFight.flags & FightState.FLAG_INITIATIVE_WEST  ? atkStateString : defendStateString;
		}
		
		
		if (manFight.flags & FightState.FLAG_ENEMY_NORTH) {
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY, 2))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowUp.label = manFight.flags & FightState.FLAG_INITIATIVE_NORTH   ? atkStateString : defendStateString;
		}
		
		if (manFight.flags & FightState.FLAG_ENEMY_SOUTH) {
			defendStateString = ( manFight.mustRollNow(fState=FightState.getNeighbour(dungeon, dungeon.man.mapX, dungeon.man.mapY,3))  ? STR_DEFEND : STR_DEFEND_TEMP );
			atkStateString = radioDefend.selected ? defendStateString + DELIBERATE_DEFEND_SUFFIX :  ( manFight.mustRollNow(fState)  ? STR_ATTACK : STR_AIM );
			arrowDown.label = manFight.flags & FightState.FLAG_INITIATIVE_SOUTH   ? atkStateString : defendStateString;
		}
		
		if (gotEnemy) {  // TODO: proper context-facing info of enemy fight info instead...later on...
			setFightInfo(manFight);
		}
		
		if (manFight.s == 2) {
			btnWait.label = STR_DONE;
			var engagedMultiple:Boolean = manFight.numEnemies > 1;
			arrowRight.visible =engagedMultiple &&  (manFight.flags & 1) !=0;
			arrowLeft.visible = engagedMultiple &&  (manFight.flags & 2) !=0;
			arrowUp.visible = engagedMultiple &&  (manFight.flags & 4)!=0;
			arrowDown.visible = engagedMultiple &&  (manFight.flags & 8) != 0;
			arrowRight.label = STR_TARG;
			arrowLeft.label = STR_TARG;
			arrowUp.label = STR_TARG;
			arrowDown.label = STR_TARG;
			
		}
		
		
	}
	
	private function sizeBtn(btn:PushButton, width:Number = 30, height:Number = 20 ):PushButton {
		btn.width = width;
		btn.height = height;
		return btn;
	}
	
	private function onAddedToStage(e:Event):void 
	{
		arrowControls = new Sprite();
		infoPanel = new VBox();
		
		infoPanel.x = 2;
		infoPanel.y = 2;
		addChild(arrowControls);
		addChild(infoPanel);
		
		arrowControls.x = stage.stageWidth - 70;
		arrowControls.y = stage.stageHeight - 60;
		arrowUp = sizeBtn( new PushButton(arrowControls, 0, -25, STR_MOVE) );
		arrowDown = sizeBtn( new PushButton(arrowControls, 0, 25, STR_MOVE) );
		arrowLeft =  sizeBtn( new PushButton(arrowControls, -30, 0, STR_MOVE) );
		arrowRight =  sizeBtn( new PushButton(arrowControls, 30, 0, STR_MOVE) );
		btnWait =  sizeBtn( new PushButton(arrowControls, 0, 0, STR_WAIT) );
		
		
		infoExchange = new Label(infoPanel, 0, 0, "Exchange #1");
		infoMoveStep = new Label(infoPanel, 0, 0, "Move 0/1");
		radioAttack = new RadioButton(infoPanel, 0, 0, "Roll Attack", true, onRadioClick);
	//	radioAttack.enabled = false;
		radioDefend = new RadioButton(infoPanel, 0, 0, "Roll Defense", false, onRadioClick);
	
		
		
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
	}
	
	private function onRadioClick(e:Event):void 
	{
		radioDefend.label = radioDefend.selected ? "Roll Defense!" : "Roll Defense";
	}
	
	public static const ROLLING_TEXT:String = "Rolling..";
	
	public function setFightInfo(fight:FightState):void {
		infoExchange.text = "Exchange #" + (fight.e ? "2" : "1");
		infoMoveStep.text = !ROLLING_TEXT || fight.s < 2 ? "Move " + fight.s + "/1" : ROLLING_TEXT;
		radioAttack.enabled = fight.initiative;
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
	private var uiTros:UITros;

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
		
		fightStack.length = 0;
		
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
        stage.addEventListener("keyDown", onKeyDown );
        stage.addEventListener("keyUp", onKeyUp );
        
        mask = new Bitmap( new BitmapData(1,1) );
        mask.scaleX=Data.gameWidth; mask.scaleY=Data.gameHeight;
        mask.x=(stage.stageWidth*stage.scaleX-Data.gameWidth)/2; mask.y=(stage.stageHeight*stage.scaleY-Data.gameHeight)/2;
        addChild(mask);
    }
    
	/*
	private function onKeyDownCheck(e:KeyboardEvent):void {
		var kc:uint = e.keyCode;
		switch (kc) {
			case Keyboard.UP:
			case Keyboard.DOWN:
			case Keyboard.LEFT:
			case Keyboard.RIGHT:
			
			break;
			default:return;
		}
		onKeyDown(e);
	}
	*/
	
    //新しい階層を設定する
    private function initFloor(flr:int):void {
        Data.makeMap( this, flr );
        Data.stand( this );　//マップを立体化
        mapBitmap.bitmapData = MapUtil.mapBitmap( this );
        onFrame();
		
		handleTimestampUpdate();
    }
	
	private function handleTimestampUpdate():void {
		if (!man.bumping) FightState.updateSurroundingStates(this, man.mapX, man.mapY, mapWidth >= mapHeight ? mapWidth : mapHeight);
		uiTros.mapUpdate(this);
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
		 onKeyUp(null  );
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
                        for each( o in map[i][j] ){ if (o.moving) o.slide(); }
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
							o.slide();
						}
					}
                } }
				
                view.camera.x = man.x;
                view.camera.y = -256 + man.y;
                if (  canInteract && keyEvent != null ) {   // assumed player has interacted with the map somewhat    // count % 6 == 0
					
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
    public function slide():void{
       // if( moving ){
            if( dungeon.check( mapX+moveArray[0], mapY+moveArray[1], "block" ).length == 0 ){
                dungeon.map[mapX][mapY].splice( dungeon.map[mapX][mapY].indexOf(this), 1 );
                mapX += moveArray[0]; mapY += moveArray[1]; 
                addTween( { x:x+Data.cellSize*moveArray[0], y:y+Data.cellSize*moveArray[1] }, moveArray[2]);
                dungeon.map[mapX][mapY].push(this)
            }else{ addTween( {}, moveArray[2]); }
            moving = false
			bumping = false;
       // }
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
    static public function walk(man:GameObject, dir:String):void{
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
        if ( !man.dungeon.checkBumpable(man.mapX + arr[0], man.mapY + arr[1]) ) man.moving = true;
	   else man.bumping = true;
		
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
            switch( enm.param.walkType ){
                case "room": if( enm.dungeon.check(enm.dungeon.man.mapX,enm.dungeon.man.mapY,"room").length == 0 ){ random(enm); break; }
				case "chase": chase(enm); break;
                default: random(enm); break;
            }
    }
	
	
    static public function walk(enm:GameObject):void{
        var arr:Array = [[1,0],[-1,0],[0,1],[0,-1]]["rlbf".indexOf(enm.dir)];
        enm.moveArray = arr;
        enm.moveArray[2] = GameObject.WAITKEY_STEP_NUM_FRAMES; //移動スピード  // movement tween duration 
       if ( !enm.dungeon.checkBumpable(enm.mapX + arr[0], enm.mapY + arr[1]) ) enm.moving = true;
	   else enm.bumping = true;
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

class FightState {
	public var s:int = 0;  // the current step within the exchange
	public var e:Boolean = false;  // false for exchange 1/2, true for exchange 2/2
	public var side:int = 1;
	
	public static const DIRECTIONS:Array =  [[1, 0], [ -1, 0], [0, 1], [0, -1]];
	
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
	public var numEnemies:int = 0;
	public var initiative:Boolean = true;
	
	// by right, these position values shouldn't be here, duplicate stored values at given timestamp
	public var x:int;
	public var y:int;
	
	public var timestamp:uint = uint.MAX_VALUE;  // lol, unlikely to happen

	
	//arrowRight.visible = !(wallMask & 1);
	//arrowLeft.visible = !(wallMask & 2);
	//arrowUp.visible = !(wallMask & 4);
	//arrowDown.visible = !(wallMask & 8);

	
	
	public function FightState() {
		
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
		
		  for(var i:uint = 0; i< mapWidth; i++ ){
            for (var j:uint = 0; j < mapHeight; j++ ) {
				var vec:Vector.<GameObject> = dungeon.checkComponent(i, j, "fight");
				var b:int = vec.length;
				while (--b > -1) {
					var fState:FightState = vec[b].components.fight;
					if (fState.timestamp != dungeon.timestamp) {
						fState.timestamp = dungeon.timestamp;
						var lastNumEnemies:int = fState.numEnemies;
						//if (fState.s < 2 ) {
						updateNeighborEnemyStates(vec[b], fState, dungeon);
						dungeon.fightStack.push(fState);
						//}
						
						if (lastNumEnemies > 0) {
							if (  fState.numEnemies == 0 ) {
								fState.reset(true);
								
							}
							else {
								fState.step();
								
							}
						}
						
							
						
					}
					
				}
			}
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
						
						manFight.numEnemies++;
						manFight.flags |= (1 << i);  
						
					}
				}
			}
			
		}
	}
	
	public static function updateNeighborInitiative(manFight:FightState, dungeon:Dungeon):void { 
		var directions:Array = DIRECTIONS;  
		var len:int = directions.length;

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
				manFight.flags |= manFight.canRollAtkAgainst(enemyFight) ? ( 1 << (OFFSET_INITIATIVE+i)) : 0;
				manFight.flags |= manFight.isSyncedWith(enemyFight) ? FLAG_INITIATIVE_SYNCED : 0;
					
				
			//}
			
		}
		
		 // cancel step() action done earlier if required, becos when not synced with anyone, will always wait at schedule zero as if unengaged.
		 // so that can rejoin the fight sync at exchange 1, step 0 always..
		if ( !(manFight.flags & FLAG_INITIATIVE_SYNCED) ) { 
			manFight.s = 0;
			manFight.e = false;
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
	
	public function reset(disengaged:Boolean=false):FightState {
		s = 0;
		e = false;
		initiative = true;
		if (disengaged) {
			numEnemies = 0;
			flags = 0;
		}
		return this;
	}
	
	public function syncStepWith(fight:FightState):void {
		if (fight.s >  s) {  
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
		return  e == 0 && s < 2;
	}
	
	public function withinInitiativeScope(fight:FightState):Boolean {
		return ( isSyncedWith(fight) || (fight.firstExchangeWindow() && firstExchangeWindow()) );
	}
	
	public function canRollAtkAgainst(fight:FightState):Boolean {
		return initiative && withinInitiativeScope(fight);  //initiative  && 
	}
	
}


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
        "man": { type:"man", state:"w0", visual:"stand",  func:{ key:Man.key }, components:{fight:new FightState().setSideAggro(FightState.SIDE_FRIEND)}, ability:{ map:false,block:true }, anim:Man.anim, animState:"walk1", dir:"f" },
        "enemy": { type:"enemy", state:"w0", num:"1", func:{ key:Enemy.key },  visual:"stand", components:{fight:new FightState().setSideAggro(FightState.SIDE_ENEMY)}, ability:{ map:false,block:true }, anim:Enemy.anim, animState:"walk", dir:"f" },
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