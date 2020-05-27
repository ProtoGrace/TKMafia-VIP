package kabam.rotmg.market.tabs {
   import com.company.assembleegameclient.game.GameSprite;
   import flash.display.Sprite;
   
   public class MemMarketTab extends Sprite {
       
      
      public var gameSprite_:GameSprite;
      
      public function MemMarketTab(gameSprite:GameSprite) {
         super();
         this.gameSprite_ = gameSprite;
         graphics.clear();
         graphics.lineStyle(1,6184542);
         graphics.moveTo(265,100);
         graphics.lineTo(265,525);
         graphics.lineStyle();
      }
      
      public function dispose() : void {
         this.gameSprite_ = null;
         for(var i:int = numChildren - 1; i >= 0; i--) {
            removeChildAt(i);
         }
      }
   }
}
