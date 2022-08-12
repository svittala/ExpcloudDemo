({
	execMassUpdate : function(component,selectedRows,objectChanges) {
        console.log('execMassUpdate: START');
        
        console.log('execMassUpdate: provided changes',JSON.stringify(objectChanges));
        let modifiedObject = {};
        for (let field in objectChanges) {
            if (objectChanges[field]) modifiedObject[field] = objectChanges[field];
        }
        console.log('execMassUpdate: modifiedObject init',JSON.stringify(modifiedObject));
        
        console.log('execMassUpdate: provided rows',JSON.stringify(selectedRows));
        let modifiedRows = [];
        selectedRows.forEach(function(item){
            console.log('execMassUpdate: processing item',JSON.stringify(item));
            let newRow = Object.assign({}, modifiedObject);
            console.log('execMassUpdate: newRow initialized',JSON.stringify(newRow));
            newRow.Id = item.Id;
            console.log('execMassUpdate: newRow updated',JSON.stringify(newRow));
            modifiedRows.push(newRow);
        });
        console.log('execMassUpdate: modifiedRows init',JSON.stringify(modifiedRows));

        component.find('soqlUtil').runDML(
           'update',
           modifiedRows,
           function(dmlResult,dmlError) {
               console.log('execMassUpdate: result from DML');
               if (dmlResult) {
                   console.log('execMassUpdate: dmlResult received',dmlResult);
          
                   let message = {
                       "title"   : modifiedRows.length + ' records updated.',
                       "severity": "confirm",
                       "content" : (Object.keys(modifiedRows[0])).length - 1
                                 + " fields updated on these records." 
                       }
                   component.set("v.message",message);
                   
                   /*
                   component.find('notifUtil').showNotice({
                       "variant": "info",
                       "header": "Modifications done !",
                       "message": modifiedRows.length + ' elements updated.',
                       closeCallback : function() {
                           console.log('execMassUpdate: closing popup');
                           component.find("overlayLibrary").notifyClose();
                           console.log('execMassUpdate: refreshing page');
                           $A.get('e.force:refreshView').fire();
                       }
                   });
                   */
                   //component.find("overlayLibrary").notifyClose();
                   
                               
               } else {
                   console.error('fetchResults: triggering query error notification',JSON.stringify(error));
                   let message = {
                       "title"   : 'Error when modifying ' + modifiedRows.length + ' records.',
                       "severity": "error",
                       "content" : JSON.stringify(dmlError) 
                       }
                   component.set("v.message",message);
                   /*
                   component.find('notifUtil').showNotice({
                                  "variant": "error",
                                  "header": "Error in DML !",
                                  "message": JSON.stringify(dmlError)
                   });
                   */
               }
               
               
         });
       
        console.log('execMassUpdate: END');
	}
})