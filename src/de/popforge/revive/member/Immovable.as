package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.BoundingBox;
	import flash.display.Graphics;
	
	public class Immovable
	{
		/*
			avoid float errors
			(very small penetration will be catched)
		*/
		static internal const EPLISON_DT: Number = -.0000001;

		/*
			avoid very slow moving objects while contact
			(too much computations)
			and tangential zero reflection for curves
			(which cause no change of velocity while collision resolve)
		*/
		static internal const MIN_REFLECTION: Number = .05;
		
		//-- physical properties
		public var elastic: Number;
		public var drag: Number;
		
		public var bounds: BoundingBox;
		
		public function Immovable()
		{
			//-- default values
			elastic = .5;
			drag = .04;
		}
		
		public function setElastic( elastic: Number ): void
		{
			if( elastic > 0 )
			{
				this.elastic = elastic;
			}
		}
		
		public function getElastic(): Number
		{
			return elastic;
		}
		
		public function setDrag( drag: Number ): void
		{
			this.drag = drag;
		}
		
		public function getDrag(): Number
		{
			return drag;
		}
	}
}