package eu.stefaner.organicedunet.semanticsearch.treeexplore_vertical {
	import eu.stefaner.organicedunet.semanticsearch.EdgeData;
	import eu.stefaner.organicedunet.semanticsearch.NodeData;

	import flare.vis.data.NodeSprite;

	/**
	 * @author mo
	 */
	public class RelatedNode extends Node {

		public var visNode : NodeSprite;
		public var relationTypes : Array = [];

		public function RelatedNode(d : NodeData, n : NodeSprite) {
			super(d);
			visNode = n;
		}

		public function updateRelationLabel() : void {
			var s : String = "";
			var a : Array = [];
			for each(var rt:String in relationTypes) {
				//a.push("<font size='10' color='#" + EdgeData.getColorForType(rt).toString(16).replace("0x", "") + "'>" + rt + "</font><br>");
				a.push(rt);
			}
			s += "<font size='10' color='#999999'>" + a.join("<br>") + "</font><br>";
			s += (data as NodeData).label;
			label_tf.htmlText = s;
			updateLayout();
		}
	}
}
