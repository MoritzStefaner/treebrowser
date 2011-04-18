package eu.stefaner.organicedunet.semanticsearch {
	import flare.util.palette.ColorPalette;

	import org.osflash.thunderbolt.Logger;

	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class EdgeData {

		private static var colorForType : Dictionary = new Dictionary();
		private static var colorCounter : Number = 0;
		private static var colorPalette : Array = ColorPalette.CATEGORY_COLORS_ALT_19;
		public var type : String = "";
		public var color : uint;
		public var label : String;

		public function EdgeData(type : String, label : String = "") {
			this.type = type;
			this.color = getColorForType(type);
			this.label = label != "" ? label : type;
		}

		public static function getColorForType(t : String) : uint {
			if(colorForType[t]) {
				return colorForType[t];
			} else {
				return colorForType[t] = colorPalette[(colorCounter++) % colorPalette.length];
			}
		}
	}
}
