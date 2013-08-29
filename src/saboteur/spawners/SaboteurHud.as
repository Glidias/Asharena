package saboteur.spawners 
{
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.a3d.systems.text.TextBoxChannel;
	import alternativa.a3d.systems.text.TextSpawner;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import ash.core.Engine;
	import assets.fonts.ConsoleFont;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import input.KeyPoll;
	import views.ui.text.TextLineInputter;

	import util.SpawnerBundle;
	/**
	 * Consolidating all stuff for HuD and determining number of draw calls used for it
	 * @author Glenn Ko
	 */
	public class SaboteurHud extends SpawnerBundle
	{
		public var minimapMaterial:TextureMaterial;  // minimap texture
		public var radarMaterial:TextureMaterial;  // circle masked
		
		public var bgOverlayFillMaterial:FillMaterial= new FillMaterial(0x666666, .4);
		public var radar_endPointDead:FillMaterial= new FillMaterial(0xFF0000, 1);
		public var radar_endPointAvailable:FillMaterial= new FillMaterial(0xFF0000, 1);
		
		private var material_icon_canBuild:FillMaterial = new FillMaterial(0xFF0000, 1);
		public function setBuildState(state:int):void {
			
		}
		
		// Possible to combine both texture atlases....for single Spriteset, for now, keep it seperate for easy development
		
		// Skin textures for HuD  (for now, leave this out)
		public var skinsSpriteSet:SpriteSet;
		public var skins:TextureAtlasMaterial;  // a texture atlas for the entire skinned UI 
		
		// Icons for HuD
		public var toolsSpriteSet:SpriteSet;
		public var tools:TextureAtlasMaterial; //
	
		// The differnet font settings
		public var txt_numpad:FontSettings;  // these can be baked 1-10, or even put to skin!
		public var txt_chat:FontSettings;	// dynamic text
		public var txt_tips:FontSettings;
		public var txt_chatChannel:TextBoxChannel;
		public var txt_tipsChannel:TextBoxChannel;
		
		private var txt_chatInput:FontSettings;
		private var chatTextInput:TextLineInputter;
		private var keypollToDisable:KeyPoll;
		private var chatInputWidth:Number = 300;
		
		static public const MAX_CHARS:int = 60;
		private var consoleFont:ConsoleFont = new ConsoleFont();
		
		private var txtSpawner:TextSpawner;
		private var _stage:Stage;
		
		public function SaboteurHud(engine:Engine, stage:Stage, keypollToDisable:KeyPoll=null) 
		{
			chatTextInput = new TextLineInputter(stage);
			this.keypollToDisable = keypollToDisable;
			
			txtSpawner = new TextSpawner(engine);
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkEnter);
			
			super();
		}
		
		private function checkEnter(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.ENTER && !chatTextInput.activated) {
				
				activateChatInput();
			}
		}
		
		
		override protected function init():void {
			setupTools();  
			setupText();
			setupMinimapAndRadar();
			
			super.init();
		}
		
		private function setupMinimapAndRadar():void 
		{
			
		}
		
	
		
		private function activateChatInput():void {
			chatTextInput.activate();
			if (keypollToDisable != null) {
				keypollToDisable.disable();
			}
			
			//  this will automaticlaly write
			txt_chatInput.writeFinalData("|", 0, 0, chatInputWidth, false, 0);
		}
		private function deactivateChatInput():void {
			chatTextInput.deactivate();
			if (keypollToDisable != null) {
				keypollToDisable.enable();
			}
		}
		
		// Utility to bind layout AABBs against Object3D position or (Start Index position on SpriteData, with optional layouting sceheme with range or custom method ). 
		public function layoutItems():void {
			
		}
		
		public function addToHud3D(obj:Object3D):void {
			// tools
			
			// minimap and radar
			
			
			// text
			obj.addChild(txt_tips.spriteSet);
			obj.addChild(txt_numpad.spriteSet);
			obj.addChild(txt_chat.spriteSet);
			obj.addChild(txt_chatInput.spriteSet);
		}
		
		public function writeChatText(text:String):void {
			txt_chatChannel.appendMessage(text);
		}
		public function writeTipText(text:String):void {
			txt_tipsChannel.appendMessage(text);
		}
		
		public function refreshChatText():void {
			txt_chatChannel.refresh();
		}
		public function refreshTipText():void {
			txt_tipsChannel.refresh();
		}
		
		
		
		
		private function setupText():void 
		{
			consoleFont.bmpResource.upload(context3D);
			var geom:Geometry  = SpriteGeometryUtil.createNormalizedSpriteGeometry(MAX_CHARS, 0, 1, 1, 0, 0, 2);
			geom.upload(context3D);
			
			
			var mat:MaskColorAtlasMaterial;
			
			mat = getNewFontMaterial(0xDDEEAA);
			txt_numpad = new FontSettings(consoleFont, mat , getNewTextSpriteSet(10, mat, geom) );
			
			mat = getNewFontMaterial(0xDDEEAA);
			txt_tips = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_tipsChannel = new TextBoxChannel(new <FontSettings>[txt_tips], 5, -1, 3);
			
			mat = getNewFontMaterial(0xDDEEAA);
			txt_chat = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_chatChannel = new TextBoxChannel(new <FontSettings>[txt_chat], 5, -1, 3);
			
			txt_chatInput = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			
			chatTextInput.onTextChange.add( onChatTextChange);
			chatTextInput.onTextCommit.add( onChatTextCommit);
			chatTextInput.onTextEscape.add( onChatTextESC);
			
			txtSpawner.addTextBoxChannel( txt_chatChannel);
			txtSpawner.addTextBoxChannel( txt_tipsChannel);
			
		}
		
		private function onChatTextCommit(str:String):void 
		{
			if (str != "" ) { 
				
				txt_chatChannel.appendMessage(str);
				txt_chatChannel.refresh();
			}
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextESC(str:String):void 
		{	
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextChange(str:String):void 
		{
			// todo: bind width to layout
			txt_chatInput.writeFinalData(str+"|", 0, 0, chatInputWidth, false, 0);
		}
		
		private function getNewFontMaterial(color:uint):MaskColorAtlasMaterial {
			var mat:MaskColorAtlasMaterial =  new MaskColorAtlasMaterial(consoleFont.bmpResource);
			mat.color = color;
			mat.alphaThreshold = .8;
			mat.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		
		private function getNewTextSpriteSet(estimatedMaxChars:int, material:Material, geom:Geometry):SpriteSet {
			var spr:SpriteSet = new SpriteSet(0, true, material, consoleFont.bmpResource.data.width, consoleFont.bmpResource.data.height, estimatedMaxChars, 2 );
			
			return spr;
		}
		
		private function setupTools():void 
		{
			
		}

		
	}

}