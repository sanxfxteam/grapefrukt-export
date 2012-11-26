package com.grapefrukt.exporter.simple {
	import com.grapefrukt.exporter.extractors.AnimationExtractor;
	import com.grapefrukt.exporter.simple.CustomExport;	
	import com.grapefrukt.exporter.settings.Settings;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	public class MultiExport {
		public function MultiExport(root:DisplayObjectContainer, clips:Array, spriteEngine:Boolean = false):void
		{
			for each(var c:MovieClip in clips)
			{
				if (spriteEngine)
				{
					Settings.scaleFactor = 1/20;
					Settings.exportMatrix = true;
				}
				var export:CustomExport = new CustomExport(root);
				AnimationExtractor.extract(export.animations, c);
				export.export();
			}
		}
	}

}