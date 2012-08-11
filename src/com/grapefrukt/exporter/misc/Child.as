/*
Copyright 2011 Martin Jonasson, grapefrukt games. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of
      conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice, this list
      of conditions and the following disclaimer in the documentation and/or other materials
      provided with the distribution.

THIS SOFTWARE IS PROVIDED BY grapefrukt games "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL grapefrukt games OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those of the
authors and should not be interpreted as representing official policies, either expressed
or implied, of grapefrukt games.
*/

package com.grapefrukt.exporter.misc {

	import com.grapefrukt.exporter.debug.Logger;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import com.grapefrukt.exporter.animations.AnimationFrame;

	/**
	 * ...
	 * @author Martin Jonasson, m@grapefrukt.com
	 */
	
	public class Child {
		public var name		:String = "";
		public var spriteid :String = "";
		public var frame	:int = 0;
		public var rect		:Rectangle;
		public var text		:String;
		public var textsize :Number;
		public var textalign:Number;
		public var bgcolor	:uint;
		public var visible	:Vector.<Boolean>;
		public var frames	:Vector.<AnimationFrame>;
		public var display	:DisplayObject;
		
		public function Child(name:String, dobj:DisplayObject, frame:int, totalframes:int) {
			this.display = dobj;
			this.frame = frame;
			this.spriteid = getClassnameMovieclip(dobj);
			this.rect = dobj.getBounds(dobj);
			this.name = name;
			if (dobj is TextField)
			{
				var t:TextField = TextField(dobj);
				this.text = t.text;
				var tf:TextFormat = t.defaultTextFormat;
				this.bgcolor = uint(tf.color);
				this.textsize = Number(tf.size) * 0.5;
				switch (tf.align)
				{
				default:
				case TextFormatAlign.CENTER:
					this.textalign = 0x21;
					break;
				case TextFormatAlign.LEFT:
					this.textalign = 0x22;
					break;
				case TextFormatAlign.RIGHT:
					this.textalign = 0x23;
					break;
				}
			}
			if (dobj is MovieClip || dobj is Shape)
			{
				var bounds:Rectangle = dobj.getBounds(dobj.parent);
				var offsetX = dobj.x - bounds.x;
				var offsetY = dobj.y - bounds.y;
				var matrix:Matrix = dobj.transform.matrix;
				matrix.tx = offsetX;
				matrix.ty = offsetY;
				var bd:BitmapData = new BitmapData(dobj.width, dobj.height); 
				bd.draw(dobj, matrix);
				bgcolor = bd.getPixel(rect.width / 2, rect.height / 2);
				//Logger.log("MovieClip/Shape", "color", bgcolor.toString());
			}
			this.visible = new Vector.<Boolean>(totalframes, false);
			this.frames = new Vector.<AnimationFrame>(totalframes, null);
		}
		
		public function getSpriteId(): String {
			return replaceAll(this.spriteid, '_', '-');
		}
		
		public function getRect():Rectangle {
			return rect;
		}
		
		public static function replaceAll(strSource:String, strReplaceFrom:String, strReplaceTo:String):String {
			return strSource == null ? null : strSource.replace(new RegExp(strReplaceFrom, 'g'), strReplaceTo);
		}
		
		public function setFrame(frame:uint, af:AnimationFrame) {
			frames[frame] = af;
		}
		
		public function setVisible(frame:uint) {
			//Logger.log("Child", name + " isvisible at frame:", frame.toString());
			visible[frame] = true;
		}

		public static function getClassnameMovieclip(instance:*): String {
			var name:String = getQualifiedClassName(instance);
			// strips package/namespace names
			name = name.replace( /.*(\.|::)/, '');
			// strips gfx from the end
			name = name.replace(/gfx/i, '');
			return name;
		}
	}
}