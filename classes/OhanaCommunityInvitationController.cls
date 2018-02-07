/**
 * @author: Enrico Murru
 * @created: 2018-01-18
 * @description: Case Standard Controller to invice people on slack (getting info from Case)
 */
public class OhanaCommunityInvitationController {
    public Case ticket{get;set;}
    public String response{get;set;}
    public Boolean enableInvitation{
        get{
            return this.ticket != null
                && this.ticket.RecordType.DeveloperName == 'Community_Management';
        }
    }
    public OhanaCommunityInvitationController(ApexPages.StandardController cnt){
        this.ticket = [Select Id, isClosed, RecordType.DeveloperName, FirstName__c, LastName__c, SuppliedEmail 
                       From Case Where Id = :cnt.getId()];
    }
    public void inviteToSlack(){
        try{
            Map<String,Object> result = SlackUtils.usersAdminInvite(
                this.ticket.FirstName__c, 
                this.ticket.LastName__c,
                this.ticket.SuppliedEmail, 
                this.ticket.IsClosed
            );
    
            Boolean ok = (Boolean)result.get('ok');
            if(ok){
                this.ticket.Status = 'Closed';
                update this.ticket;
                insert new CaseComment(ParentId = this.ticket.Id, CommentBody = JSON.serialize(result));
                this.response = 'Invited!';
            }else{
                result.remove('_endpoint');
                this.response = 'Invitation not succeded: \n\n'+JSON.serializePretty(result);
            }
        }catch(Exception e){
            this.response = 'Something bad happened: '+e.getMessage();
        }
    }
}