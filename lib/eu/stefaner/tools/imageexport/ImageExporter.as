package eu.stefaner.tools.imageexport {

	import com.adobe.images.PNGEncoder;
	import com.formatlos.as3.lib.display.BitmapDataUnlimited;
	import com.formatlos.as3.lib.display.events.BitmapDataUnlimitedEvent;

	import org.osflash.thunderbolt.Logger;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * @author mo
	 */
	public class ImageExporter {

		public static function saveImage(s:Stage, width : uint = 4000, height : uint = 4000, fileName : String = "imageExport.png", transparent : Boolean = true, bgColor : uint = 0) : void {
			Logger.info("ImageExporter.saveImage ", arguments.join(","));

			var bdu : BitmapDataUnlimited = new BitmapDataUnlimited();
			bdu.addEventListener(BitmapDataUnlimitedEvent.COMPLETE, onBmpReady);

			// black
			bdu.create(width, height, transparent, bgColor);

			function onBmpReady(event : BitmapDataUnlimitedEvent) : void {
				Logger.info("bmpdata created");
				var _bmpd : BitmapData = bdu.bitmapData;
				Logger.info("drawing");
				_bmpd.draw(s);
				Logger.info("encoding");
				var ba : ByteArray = PNGEncoder.encode(_bmpd);
				Logger.info("done");
				new FileReference().save(ba, fileName);
				ba.clear();
			}
		}

	}
}
