/**********************************************************************
Name:  Sip_ProposalRequestFormParameters
-------
======================================================
======================================================
Purpose: 
-------
It is used to handle Proposal Request Form query functions.
======================================================
======================================================
History
-------
VERSION  AUTHOR            DATE              DETAIL                 Description
1.0      Crystal           05/29/2019        INITIAL DEVELOPMENT    CSR:
***********************************************************************/
public without sharing class Sip_ProposalRequestFormParameters {

	private String userId;
	private String accId;
    private Set<Id> acctIdSet;
    private Set<Id> prfIdSet;
    private Set<Id> oppoIdSet;

    public Sip_ProposalRequestFormParameters() {}

    public void setUserId(String userId) {
    	this.userId = userId;
    }

    public string getUserId() {
    	return this.userId;
    }

    public void setAccId(String accId) {
    	this.accId = accId;
    }

    public string getAccId() {
    	return this.accId;
    }

    public void setAccIdSet(Set<Id> acctIdSet) {
        this.acctIdSet = new Set<Id>(acctIdSet);
    }

    public Set<Id> getAccIdSet() {
        if (this.acctIdSet != null) {
            return this.acctIdSet;
        } else {
            return new Set<Id>();
        }
    }

    public void setPRFIdSet(Set<Id> prfIdSet) {
        this.prfIdSet = new Set<Id>(prfIdSet);
    }

    public Set<Id> getPRFIdSet() {
        if (this.prfIdSet != null) {
            return this.prfIdSet;
        } else {
            return new Set<Id>();
        }
    }

    public void setOppoIdSet(Set<Id> oppoIdSet) {
        this.oppoIdSet = new Set<Id>(oppoIdSet);
    }

    public Set<Id> getOppoIdSet() {
        if (this.oppoIdSet != null) {
            return this.oppoIdSet;
        } else {
            return new Set<Id>();
        }
    }
}