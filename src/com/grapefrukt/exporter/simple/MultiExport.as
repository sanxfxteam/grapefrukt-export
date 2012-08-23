package com.grapefrukt.exporter.simple {
	import com.grapefrukt.exporter.extractors.AnimationExtractor;
	import com.grapefrukt.exporter.simple.CustomExport;	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;

	public class MultiExport {
		public function MultiExport(root:DisplayObjectContainer, clips:Array):void
		{
			for each(var c:MovieClip in clips)
			{
				var export:CustomExport = new CustomExport(root);
				AnimationExtractor.extract(export.animations, c);
				export.export();
			}
		}
	}

}