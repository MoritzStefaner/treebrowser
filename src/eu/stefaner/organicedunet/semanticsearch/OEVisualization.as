package eu.stefaner.organicedunet.semanticsearch {
	import eu.stefaner.flareextensions.UI.InteractiveNodeSprite;
	import eu.stefaner.organicedunet.semanticsearch.treeexplore_vertical.RelatedNode;

	import flare.vis.Visualization;
	import flare.vis.axis.Axes;
	import flare.vis.data.Data;
	import flare.vis.data.NodeSprite;
	import flare.vis.data.Tree;
	import flare.vis.operator.layout.Layout;

	import org.osflash.thunderbolt.Logger;

	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author mo
	 */
	public class OEVisualization extends Visualization {

		public static const NODE_SELECTED : String = "NODE_SELECTED";
		public static const ANIMATION_STEP : String = "ANIMATION_STEP";
		public var selectedNode : NodeSprite;
		public var layout : Layout;

		public function OEVisualization(data : Data = null, axes : Axes = null) {
			super(data, axes);
		}

		public function init(d : Tree) : void {
			data = d; 
			initNodes();
			initRelations();
			initLayout();
			// changeSelection(data.root);
			addEventListener(MouseEvent.CLICK, onClick);
		}

		public function changeSelection(node : NodeSprite) : void {
			selectedNode = node;
			
			if(node is InteractiveNodeSprite) {
				data.nodes.setProperty("selected", false, null, InteractiveNodeSprite);
				(node as InteractiveNodeSprite).selected = true;
			}

			dispatchEvent(new Event(NODE_SELECTED));
		}

		public function refreshView() : void {
		}

		protected function initLayout() : void {
		}

		protected function initRelations() : void {
		}

		protected function initNodes() : void {
		}

		protected function onClick(evt : MouseEvent) : void {
			var ns : NodeSprite = evt.target as NodeSprite;
			if(ns is RelatedNode) {
				ns = (ns as RelatedNode).visNode;
			} 
			if(ns) {
				Logger.info("click", ns.data.id);
				changeSelection(ns);
			}						
		}
	}
}
