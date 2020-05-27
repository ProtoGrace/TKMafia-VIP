package kabam.rotmg.BountyBoard.SubscriptionUI {
import com.company.assembleegameclient.game.GameSprite;
import com.company.assembleegameclient.objects.Player;
import com.gskinner.motion.GTween;
import flash.events.Event;
import flash.events.MouseEvent;
import io.decagames.rotmg.ui.buttons.SliceScalingButton;
import io.decagames.rotmg.ui.popups.header.PopupHeader;
import io.decagames.rotmg.ui.popups.modal.ModalPopup;
import io.decagames.rotmg.ui.texture.TextureParser;
import kabam.lib.net.api.MessageProvider;
import kabam.lib.net.impl.SocketServer;
import kabam.rotmg.BountyBoard.SubscriptionUI.signals.BountyMemberListSendSignal;
import kabam.rotmg.core.StaticInjectorContext;
import kabam.rotmg.game.model.GameModel;
import kabam.rotmg.messaging.impl.GameServerConnection;
import kabam.rotmg.messaging.impl.incoming.bounty.BountyMemberListSend;
import kabam.rotmg.messaging.impl.outgoing.bounty.BountyMemberListRequest;
import org.osflash.signals.Signal;

public class SubscriptionUI extends ModalPopup {


    var quitButton:SliceScalingButton;

    var player:Player;

    var text_:String;

    public var gameSprite:GameSprite;

    var close:Signal;

    var clicked:Signal;

    var playerIds:Vector.<int>;

    var players:Vector.<Player>;

    public const getPlayersSignal:BountyMemberListSendSignal = new BountyMemberListSendSignal();

    public function SubscriptionUI(arg1:String, gs:GameSprite) {
        this.close = new Signal();
        this.clicked = new Signal();
        this.playerIds = new Vector.<int>();
        this.players = new Vector.<Player>();
        super(300,500,arg1);
        this.gameSprite = gs;
        this.alpha = 0;
        new GTween(this,0.2,{"alpha":1});
        this.init();
        this.x = 207.5;
        this.y = 22.5;
        this.player = StaticInjectorContext.getInjector().getInstance(GameModel).player;
        this.quitButton = new SliceScalingButton(TextureParser.instance.getSliceScalingBitmap("UI","close_button"));
        this.header.addButton(this.quitButton,PopupHeader.RIGHT_BUTTON);
        this.quitButton.addEventListener(MouseEvent.CLICK,this.onClose);
    }

    public function init() : void {
        var _local_1:BountyMemberListRequest = null;
        var messages:MessageProvider = StaticInjectorContext.getInjector().getInstance(MessageProvider);
        var socketServer:SocketServer = StaticInjectorContext.getInjector().getInstance(SocketServer);
        _local_1 = messages.require(GameServerConnection.BOUNTYMEMBERLISTREQUEST) as BountyMemberListRequest;
        socketServer.sendMessage(_local_1);
        this.getPlayersSignal.add(this.onGetIds);
    }

    public function onGetIds(ids:BountyMemberListSend) : void {
        for(var i:int = 0; i < ids.playerIds.length; i++) {
            this.playerIds[i] = ids.playerIds[i];
            this.players[i] = this.gameSprite.map.goDict_[this.playerIds[i]];
            trace(this.playerIds[i]);
            trace(this.players[i].name_);
        }
    }

    public function onClose(arg1:Event) : void {
        this.close.dispatch();
    }
}
}