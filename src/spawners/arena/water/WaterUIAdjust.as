package spawners.arena.water 
{
	import com.bit101.components.HSlider;
	import com.bit101.components.InputText;
	import com.bit101.components.Style;
	import com.bit101.components.Window;
	import com.bit101.utils.MinimalConfigurator;
	import com.flashartofwar.fcss.utils.FSerialization;
	import eu.nekobit.alternativa3d.materials.WaterMaterial;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class WaterUIAdjust extends Sprite
	{
		private var material:WaterMaterial;
		private var guiContainer:Sprite = new Sprite();
		
private var waterColorR:InputText;
private var waterColorG:InputText;
private var waterColorB:InputText;
private var fresnelSlider:HSlider;
private var reflectionMultiplierSlider:HSlider;
private var perturbReflectiveBy:HSlider;
private var perturbRefractiveBy:HSlider;
private var tintAmount:HSlider;
private var optionsWindow:Window;	




		
		public var _baseWaterLevelOscillate:Number = 80;
		public var _baseWaterLevel:Number = waterLevel;// -20000 + _baseWaterLevelOscillate;
		public var _waterSpeed:Number = 0;// 2.0 * .001;
		public var clipReflection:Boolean = true;

		private var _lastTime:int = -1;
		private var _waterOscValue:Number = 0;
		private var waterMaterial:WaterMaterial;
	private var waterLevel:Number = -20000;
public var reflectClipOffset:Number = 0;

		private var view:XML =

		
		<comps>	
		<!-- Console -->
		<Window id="options" title="Options (TAB-toggle debugview, F-cast ray test, MouseWheel-adjust zoom)" x="695" y="5" width="400" height="320" draggable="true" hasMinimizeButton="true">
		<VBox left="15" right="15" top="50" bottom="15" spacing="15">
		<HBox bottom="5" left="5" right="5">
		<Label text="Water tint color RGB:" />
		<InputText id="waterColorR" />
		<InputText id="waterColorG" />
		<InputText id="waterColorB" />
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water tint amount:" />
		<HSlider id="tintSlider" minimum="0.0" maximum="1.0" event="change:onTintChange"/>
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water Fresnel multiplier:" />
		<HSlider id="fresnelSlider" minimum="0.0" maximum="1.0" event="change:onFresnelCoefChange"/>
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water Reflection (fresnel -1) multiplier:" />
		<HSlider id="reflectionMultiplierSlider" minimum="0.0" maximum="1.0" event="change:onFresnelCoefChange"/>
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water Perturb reflection:" />
		<HSlider id="perturbReflectiveSlider" minimum="0.0" maximum="0.5" event="change:onPerturbChange"/>
		<Label text="Clip offset:" />
		<HSlider id="Reflect clip offset" value={reflectClipOffset} minimum="0" maximum="800" event="change:onReflectClipOffsetChange"/>
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water Perturb refraction by:" />
		<HSlider id="perturbRefractiveSlider" minimum="0.0" maximum="0.5" event="change:onPerturbChange"/>
		</HBox>
		<HBox bottom="0" left="5" right="5" alignment="middle">
		<Label text="Tide Speed/Amplitude" />
		<HSlider id="waterSpeed" value={_waterSpeed*1000} minimum="0" maximum="5" event="change:onWaterSpeedChange"/>
		<HSlider id="waterAmp" value={_baseWaterLevelOscillate} minimum="0" maximum="256" event="change:onWaterAmpChange"/>
		</HBox>
		<HBox bottom="5" left="5" right="5" alignment="middle">
		<Label text="Water Level / Terrain LOD" />
		<HSlider id="waterLevel" value={_baseWaterLevel} minimum="-20000" maximum="0" event="change:onWaterLevelChange"/>
		
		</HBox>
		<PushButton label="Enter full screen" event="click:onFSButtonClicked"/>
		</VBox>
		</Window>
		</comps>;
		
		public function WaterUIAdjust(material:WaterMaterial ) 
		{
			this.waterMaterial = material;
			createGUI();
			
		}
		
		private function createGUI():void
		{	
		// Style
		Style.setStyle(Style.DARK);
		addChild(guiContainer);
		guiContainer.addEventListener(MouseEvent.MOUSE_DOWN, stopPropagation);
		var minco:MinimalConfigurator = new MinimalConfigurator(this);
		minco.parseXML(view);
		// Get refs
		waterColorR = (minco.getCompById("waterColorR") as InputText);
		waterColorG = (minco.getCompById("waterColorG") as InputText);
		waterColorB = (minco.getCompById("waterColorB") as InputText);
		fresnelSlider = (minco.getCompById("fresnelSlider") as HSlider);
		reflectionMultiplierSlider = (minco.getCompById("reflectionMultiplierSlider") as HSlider);	
		perturbReflectiveBy = (minco.getCompById("perturbReflectiveSlider") as HSlider);
		perturbRefractiveBy = (minco.getCompById("perturbRefractiveSlider") as HSlider);
		tintAmount = (minco.getCompById("tintSlider") as HSlider);
		optionsWindow = (minco.getCompById("options") as Window);
		guiContainer.addChild(optionsWindow);
		// Set defaults
		waterColorR.text = String(waterMaterial.waterColorR);
		waterColorG.text = String(waterMaterial.waterColorG);
		waterColorB.text = String(waterMaterial.waterColorB);
		fresnelSlider.value = waterMaterial.fresnelMultiplier;
		reflectionMultiplierSlider.value = waterMaterial.reflectionMultiplier;
		perturbReflectiveBy.value = waterMaterial.perturbReflectiveBy;
		perturbRefractiveBy.value = waterMaterial.perturbRefractiveBy;
		tintAmount.value = waterMaterial.waterTintAmount;
		// Add change listeners for tfs
		waterColorR.addEventListener(Event.CHANGE, onWaterColorChange);
		waterColorG.addEventListener(Event.CHANGE, onWaterColorChange);
		waterColorB.addEventListener(Event.CHANGE, onWaterColorChange);
		}
		
		private function stopPropagation(e:MouseEvent):void 
		{
			e.stopPropagation();
		}
		

		/*---------------------
GUI event handlers
---------------------*/

public function saveMaterialSettings():String {
	return FSerialization.getStyleStringOfObject("waterMaterial", waterMaterial, 
		FSerialization.createHashFromArray(["waterColorR", "waterColorG", "waterColorB", "fresnelMultiplier", "reflectionMultiplier", "perturbReflectiveBy", "perturbRefractiveBy", "waterTintAmount" ]) );
	
}

public function onWaterColorChange(e:Event):void
{
waterMaterial.waterColorR = parseFloat(waterColorR.text);
waterMaterial.waterColorG = parseFloat(waterColorG.text);
waterMaterial.waterColorB = parseFloat(waterColorB.text);
}

public function onFresnelCoefChange(e:Event):void
{
waterMaterial.fresnelMultiplier = fresnelSlider.value;
waterMaterial.reflectionMultiplier = reflectionMultiplierSlider.value;
}	
public function onPerturbChange(e:Event):void
{
waterMaterial.perturbReflectiveBy = perturbReflectiveBy.value;
waterMaterial.perturbRefractiveBy = perturbRefractiveBy.value;
}
public function onTintChange(e:Event):void
{
waterMaterial.waterTintAmount = tintAmount.value;
}
public function onFSButtonClicked(e:Event):void
{
stage.displayState = StageDisplayState.FULL_SCREEN;	
}
		
	}

}