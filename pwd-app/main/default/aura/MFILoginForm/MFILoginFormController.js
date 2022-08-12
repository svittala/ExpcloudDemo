({
    init : function(cmp) {
        cmp.set("v.email","test@init");
        cmp.set("v.startUrl","/") ;
        cmp.set("v.errorstring","Initialized");
},
    handleLogin: function(cmp,event){
        let email = cmp.get("v.email"), 
        startUrl = cmp.get("v.starturl");
        var action = cmp.get("c.Serverlogin");
        console.log('email value'+email);
        action.setParams(
            { 
                useemail : email, 
                startUrl: startUrl,
            });
        action.setCallback(this, function(res) {
            if (action.getState() === "SUCCESS") {
                cmp.set("v.op_url", res.getReturnValue());
                 
            } 
            if (action.getState() === "ERROR") {
                cmp.set("v.error", res.getReturnValue());
            } 
            
        });
        $A.enqueueAction(action);
    }, 
    handleRedirect: function(cmp,event,helper){
        let url = cmp.get("v.op_url"); 
        window.location.href = url;  
    }
})