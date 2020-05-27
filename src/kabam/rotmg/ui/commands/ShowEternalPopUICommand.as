package kabam.rotmg.ui.commands {
   import com.gskinner.motion.GTween;
   import flash.display.DisplayObjectContainer;
   import flash.utils.setTimeout;
   import kabam.rotmg.ui.view.EternalNotifViewPng;
   import mx.core.BitmapAsset;
   
   public class ShowEternalPopUICommand {
      
      private static var EternalNotifPng:Class = EternalNotifViewPng;
       
      
      private var view:BitmapAsset;
      
      [Inject]
      public var contextView:DisplayObjectContainer;
      
      public function ShowEternalPopUICommand() {
         super();
      }
      
      public function execute() : void {
         this.view = new EternalNotifPng();
         this.view.x = 160;
         this.view.y = 200;
         this.contextView.addChild(this.view);
         this.view.alpha = 0.8;
         new GTween(this.view,0.5,{"alpha":1});
         setTimeout(function():void {
            new GTween(view,0.5,{"alpha":0});
         },2000);
         setTimeout(this.remove,2500);
      }
      
      private function remove() : void {
         this.contextView.removeChild(this.view);
         this.view = null;
      }
   }
}
