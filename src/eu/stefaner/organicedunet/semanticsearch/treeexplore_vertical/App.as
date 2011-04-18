package eu.stefaner.organicedunet.semanticsearch.treeexplore_vertical {
	import eu.stefaner.organicedunet.semanticsearch.NodeData;
	import eu.stefaner.organicedunet.semanticsearch.OEApp;
	import eu.stefaner.organicedunet.semanticsearch.OEVisualization;

	import fl.data.DataProvider;
	import fl.events.ComponentEvent;

	import flare.animate.Tween;
	import flare.vis.data.NodeSprite;

	import com.bit101.components.VScrollBar;
	import com.yahoo.astra.fl.controls.AutoComplete;

	import org.osflash.thunderbolt.Logger;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;

	/**
	 * @author mo
	 */
	public class App extends OEApp {

		public var loadingAni : Sprite;
		private var scrollBar : VScrollBar;
		public var shadow : Sprite;
		public var quicksearch : AutoComplete;
		private var visMask : Sprite;
		public var relationsAlreadyLoadedFor : Dictionary = new Dictionary();
		// scrollwheel tricks
		static private const JAVASCRIPT : String = "var browserScrolling;function allowBrowserScroll(value){browserScrolling=value;}function handle(delta){if(!browserScrolling){return false;}return true;}function wheel(event){var delta=0;if(!event){event=window.event;}if(event.wheelDelta){delta=event.wheelDelta/120;if(window.opera){delta=-delta;}}else if(event.detail){delta=-event.detail/3;}if(delta){handle(delta);}if(!browserScrolling){if(event.preventDefault){event.preventDefault();}event.returnValue=false;}}if(window.addEventListener){window.addEventListener('DOMMouseScroll',wheel,false);}window.onmousewheel=document.onmousewheel=wheel;allowBrowserScroll(true);";
		static private const JS_METHOD : String = "allowBrowserScroll";
		static private var _browserScrollEnabled : Boolean = true;
		static private var _mouseWheelTrapped : Boolean = false;

		override protected function initVisualization() : void {
			setupMouseWheel();
			visualization = new TreeExploreVisualization();
			visualization.x = visualization.y = 0;
			visualization.bounds.height = stage.stageHeight + 10;
			visualization.bounds.width = stage.stageWidth;
			
			visualization.addEventListener(OEVisualization.NODE_SELECTED, onNodeSelected);
			visualization.addEventListener(OEVisualization.ANIMATION_STEP, onAnimationStep);
			
			addChild(visualization);
			visMask = new Sprite();
			visMask.graphics.beginFill(0);
			visMask.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			addChild(visMask);
			visualization.mask = visMask;
			
			scrollBar = new VScrollBar(this, stage.stageWidth - 10, 0, onScrollBarMoved);
			scrollBar.height = stage.stageHeight;
			scrollBar.visible = false;
			addChild(scrollBar);
			shadow.mouseEnabled = false;
			addChild(shadow);
		}

		private function setupMouseWheel() : void {
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(Event.MOUSE_LEAVE, function(e : * = null):void { 
				allowBrowserScroll(true); 			
			});
		}

		private function onMouseMove(event : MouseEvent) : void {
			allowBrowserScroll(!scrollBar.visible);
		}

		static private function allowBrowserScroll(allow : Boolean) : void {
			createMouseWheelTrap();
			
			if (allow == _browserScrollEnabled)
				return;
			_browserScrollEnabled = allow;
			
			if (ExternalInterface.available) {
				ExternalInterface.call(JS_METHOD, _browserScrollEnabled);
				return;
			}
		}

		static private function createMouseWheelTrap() : void {
			if (_mouseWheelTrapped) 
				return;
			_mouseWheelTrapped = true;
			
			if (ExternalInterface.available) {
				ExternalInterface.call("eval", JAVASCRIPT);
				return;
			}
		}

		override public function onInterestPointLoaded(interestPoint : NodeSprite) : void {
			Logger.info("App.onInterestPointsLoaded", interestPoint.data.id);
			visualization.changeSelection(interestPoint);
			/*
			if(JSCallBack_selectionChange) {
				ExternalInterface.call(JSCallBack_selectionChange, [visualization.selectedNode.data]);
			} 
			 * 
			 */
		}

		protected function onMouseWheel(event : MouseEvent) : void {
			if(!scrollBar.visible) return;
			scrollBar.value -= event.delta * 4;
			visualization.y = -scrollBar.value;
		}

		public function onScrollBarMoved(e : Event) : void {
			if((visualization as TreeExploreVisualization).transitioner && (visualization as TreeExploreVisualization).transitioner.running) return;
			visualization.y = -scrollBar.value;
		}

		private function onAnimationStep(event : Event) : void {
			updateScrollPane();	
		}

		override public function showLoading(loading : Boolean) : void {
			new Tween(loadingAni, .5, {visible:loading, alpha:(loading ? 1 : 0)}).play();
		}

		override public function createNodeSprite(nd : NodeData) : NodeSprite {
			var ns : NodeSprite = new Node(nd);
			return ns;
		}

		override public function onOntologyLoaded() : void {
			for each(var n:Node in ontology.nodes) {
				n.init();
			}
			super.onOntologyLoaded();
			initQuickSearch();
		}

		private function initQuickSearch() : void {
			addChild(quicksearch);
			var a : Array = new Array();
			for each(var n:NodeSprite in ontology.nodes) {
				var o : * = {};
				o.label = (n.data as NodeData).label;
				var alreadyIn : Boolean = false;
				for each (var o2 : * in a) {
					if (o2.label == o.label) {
						alreadyIn = true;
						break;
					} 
				}
				//o.id = (n.data as NodeData).id;
				if(!alreadyIn) a.push(o);
			}
			a.sortOn("label");
			quicksearch.addEventListener(ComponentEvent.ENTER, onQuickSearchSelection);
			quicksearch.addEventListener(Event.CLOSE, onQuickSearchClose);
			quicksearch.dataProvider = new DataProvider(a);  
		}

		private function onQuickSearchClose(event : Event) : void {
			onQuickSearchSelection(event, true); 
		}

		private function onQuickSearchSelection(event : Event, fromListCloseEvent : Boolean = false) : void {
			Logger.info("picked", quicksearch.text, quicksearch.selectedItem);
			var found : Boolean = false;
			for each (var n:NodeSprite in visualization.data.nodes) {
				if((n.data as NodeData).label == quicksearch.text) {
					found = true;
					break;
				}
			}
			if(found) visualization.changeSelection(n);
			if(found || !fromListCloseEvent) {
				quicksearch.text = "";
			}
			
			if(quicksearch.text == "") {
				stage.focus = null;
			}
		}

		override protected function onNodeSelected(event : Event) : void {
			super.onNodeSelected(event);		
			updateScrollPane();
		}

		override public function onDataLoaded() : void {
			super.onDataLoaded();
			if(!relationsAlreadyLoadedFor[visualization.selectedNode]) {
				relationsAlreadyLoadedFor[visualization.selectedNode] = true;
				visualization.refreshView();
				updateScrollPane();
			}
		}

		private function updateScrollPane() : void {
			(visualization as TreeExploreVisualization).updateTotalHeight();
			
			//Logger.info(String((visualization as TreeExploreVisualization).totalHeight));
			if((visualization as TreeExploreVisualization).totalHeight > stage.stageHeight * .5) {
				scrollBar.setSliderParams(-((visualization as TreeExploreVisualization).totalHeight - stage.stageHeight * .5), 0, -visualization.y);
				scrollBar.visible = true;
				scrollBar.setThumbPercent(stage.stageHeight / ((visualization as TreeExploreVisualization).totalHeight + stage.stageHeight * .5));
			} else {
				scrollBar.visible = false;
			}
		}
	}
}
