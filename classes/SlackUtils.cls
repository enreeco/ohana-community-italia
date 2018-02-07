/**
 * @author: Enrico Murru
 * @created: 2018-01-19
 * @description: Slack utilities
 */
public class SlackUtils {
    /*
     * OAuth token for admin tasks took from https://api.slack.com/custom-integrations/legacy-tokens
     * TODO: replace with Custom Setting or Oauth Call
     */
    public static String oauthToken{
        get{
            return 'XXXX-XXXXX-XXXXX-XXXX-XXXX-XXX-XXX-XXX-XXX-XXX';
        }
    }
    
    public static Integer timeout{
        get{
            return 10000;
        }
    }
    
    public static String botUsername{
        get{
            return 'Ohana-Bot';
        }
    }
    
    public static String botIcon{
        get{
            return 'http://www.pvhc.net/img27/etkmxqpiedvgkwyioupj.png';
        }
    }
    
    /*
     * Makes a call to Slack to invite (or re-invite) a user
     * Docs: https://stackoverflow.com/questions/30955818/slack-api-team-invitation
     * 		 https://github.com/ErikKalkoken/slackApiDoc
     */
    public static Map<String,Object> usersAdminInvite(String firstName, String lastName, String email, Boolean resend){
        http h = new http();
        httprequest request = new httprequest();
        String url = 'callout:SLACK_API/users.admin.invite'
                           +'?token='+SlackUtils.oauthToken
            			   +'&email='+email
                           +'&first_name='+EncodingUtil.URLencode(firstName,'UTF-8')
                           +'&last_name='+EncodingUtil.URLencode(lastName,'UTF-8');
        if(resend == true){
            url+='&resend=true';
        }
        request.setendpoint(url);
        request.setmethod('GET');
        request.settimeout(timeout);
        httpresponse resp = h.send(request);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
        result.put('_endpoint', url);
        return result;
    }
    /*
     * Get all private channels
     */
    public static Map<String,Object> groupsList(){
        
        http h = new http();
        httprequest request = new httprequest();
        String url = 'callout:SLACK_API/groups.list?token='+oauthToken+'&exclude_archived=true&exclude_members=true';
        request.setendpoint(url);
        request.setmethod('GET');
        request.settimeout(timeout);
        httpresponse resp = h.send(request);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
        result.put('_endpoint', url);
        return result;
    }
    
    /*
     * Get all public channels
     */
    public static Map<String,Object> channelsList(){
        
        http h = new http();
        httprequest request = new httprequest();
        String url = 'callout:SLACK_API/channels.list?token='+oauthToken+'&exclude_archived=true&exclude_members=true';
        request.setendpoint(url);
        request.setmethod('GET');
        request.settimeout(timeout);
        httpresponse resp = h.send(request);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
        result.put('_endpoint', url);
        return result;
    }
    
    /*
     * Get a specific channel info
     */
    public static Map<String,Object> getChannellByName(String name, Boolean isPrivate){
        Map<String,Object> result = (isPrivate)?groupsList():channelsList();
        Boolean ok = (Boolean)result.get('ok');
        if(!ok){
            return new map<String,Object>{'ok' => false, 'error' => result};
        }
		List<Object> channels = (isPrivate)?(List<Object>) result.get('groups'):(List<Object>) result.get('channels');
        for(Object g : channels){
            Map<String,Object> gMap = (Map<String,Object>)g;
            if(name == (String)gMap.get('name')){
                return gMap;
            }
        }
        return new map<String,Object>{'ok' => false, 'error' => 'Channel not found'};
    }
    
    /*
     * Posts a simple string message to the channel
     */
    public static Map<String,Object> chatPostMessage(String message, String channelId){
        http h = new http();
        httprequest request = new httprequest();
        String url = 'callout:SLACK_API/chat.postMessage?token='+oauthToken
            +'&channel='+channelId
            +'&as_user=false'
            +'&parse=full'
            +'&username='+EncodingUtil.urlEncode(botUsername, 'UTF-8')
            +'&icon_url='+EncodingUtil.urlEncode(botIcon, 'UTF-8')
            +'&text='+EncodingUtil.urlEncode(message, 'UTF-8');
        request.setendpoint(url);
        request.setmethod('POST');
        request.setHeader('content-type', 'application/json');
        request.settimeout(timeout);
        httpresponse resp = h.send(request);
        Map<String,Object> result = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
        result.put('_endpoint', url);
        return result;
    }
}