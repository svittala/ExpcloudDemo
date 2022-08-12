({
	previewFile : function(component, event, helper) {
		var idFile = event.getSource().get("v.name");
        var openPreview = $A.get('e.lightning:openFiles');
        openPreview.fire({
            recordIds: [idFile]
        });
	}
})