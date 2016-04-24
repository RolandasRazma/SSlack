(function(){
    var protocolUUID = "|SS|";

    function log(){
        __SSlack__.log(Array.prototype.slice.call(arguments));
    }

    function setUIStateAsSecure( secure ) {
        $('#main_sslack_menu').children('.ts_icon').removeClass( "ts_icon_unlock ts_icon_lock" ).addClass( secure?"ts_icon_lock":"ts_icon_unlock" );
        $('#message-input').css('border-color', secure?'green':'');
        $('#primary_file_button').css('border-color', secure?'green':'');
    }
 
    function initUI() {

        // Add lock to text field
        var sslackToggle = $('<a class="emo_menu" id="main_sslack_menu" style="margin-right:30px;"><i class="ts_icon ts_icon_unlock"></i></a>');
        sslackToggle.click(function() {
            var model = TS.shared.getActiveModelOb();
            if ( model.user ) {
                if ( !__SSlack__.isEncrypting(model.user) ) {
                    setUIStateAsSecure( __SSlack__.startEncrypting(model.user) );
                } else if ( __SSlack__.stopEncrypting(model.user) ) {
                    setUIStateAsSecure( false );
                }
            } else {
                setUIStateAsSecure( false );
            }
        });
 
        $('#main_emo_menu').before(sslackToggle);
        $('#message-input').css('padding-right', '70px');

    }

    function initHooks() {
//        TS.log = log;
//        TS.error = log;
//        TS.warn = log;

        // Chat changed
        var channelDisplaySwitched = TS.client.channelDisplaySwitched;
        TS.client.channelDisplaySwitched = function(model_ob_id, replace_history_state, no_history_add) {
            var model = TS.shared.getModelObById(model_ob_id);
            if ( model.user ) {
                setUIStateAsSecure( __SSlack__.isEncrypting(model.user) );
            } else {
                setUIStateAsSecure( false )
            }
            return channelDisplaySwitched.apply(this, arguments)
        }
 
        // Received message
        var message = TS.templates.message;
        TS.templates.message = function(context, execOptions) {
            if ( context.msg.type === 'message' && context.msg.user && context.model_ob.user && context.msg.text ) {
                var txt = context.msg.text;
                if ( txt.length > protocolUUID.length && txt.substring(0, protocolUUID.length) === protocolUUID ) {
                    if ( (decryptedText = __SSlack__.decrypt(txt.substring(protocolUUID.length), context.model_ob.user)) ) {
                        arguments[0].msg.text = decryptedText;
                    } else {
                        arguments[0].msg.text = "SSLack: Broken crypto.";
                    }
                }
            }

            return message.apply(this, arguments);
        }
 
        // Send message
        var sendMessage = TS.client.ui.sendMessage;
        TS.client.ui.sendMessage = function(model_ob, txt, in_reply_to_msg) {
            if ( model_ob.user && __SSlack__.isEncrypting(model_ob.user) ) {
                if ( (encryptedText = __SSlack__.encrypt(txt, model_ob.user)) ) {
                    arguments[1] = protocolUUID + encryptedText;
                } else {
                    return;
                }
            }

            return sendMessage.apply(this, arguments);
        }
    }


    r(function(){
        initUI();
        initHooks();
    });
    function r(f){/in/.test(typeof TS)?setTimeout('r('+f+')', 9):f()}
})();