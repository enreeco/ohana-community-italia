/**
 * @author: Enrico Murru
 * @created: 2018-01-19
 * @description: Async Job to query for open cases: if so notifies the 'ohana-service' slack private group
 */
global class NotifyNewUsersOnSlackSch implements Schedulable {
    
    public static String ohanaServiceChannel{
        get{
            return 'ohana-service';
        }
    }
    
    private static Integer getOpenCases(){
        return [Select count() From Case 
                             Where RecordType.DeveloperName = 'Community_Management' 
                             and IsClosed = false];
    }
    
	global void execute(SchedulableContext SC) {
        Integer openCases = getOpenCases();
        if(openCases == 0) return;
        
		System.enqueueJob(new QueableCallouts());
	}


    public class QueableCallouts implements Queueable, Database.AllowsCallouts {
        public void execute(QueueableContext context) {
			Integer openCases = getOpenCases();
            Map<String,Object> cInfo = SlackUtils.getChannellByName(ohanaServiceChannel, true);
			String cid = (String)cInfo.get('id');
			Map<String,Object> msg = 
                SlackUtils.chatPostMessage('@channel *There are '
                                           + openCases
                                           + ' invitation cases open!* :scream: \nPlease handle them! ',cid);      
        }
    }
    
}