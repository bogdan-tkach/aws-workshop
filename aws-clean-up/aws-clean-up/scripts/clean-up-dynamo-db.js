
let deleteTable = (dynamodb, tableName) => {
    var params = {
        TableName: tableName
       };
    dynamodb.deleteTable(params, function(err, data) {
        if (err) {
            console.log(`Could not delete table ${tableName}`); 
            console.log(err, err.stack);
        }else {
            console.log(`Removed table ${tableName}`); 
            console.log(data);           // successful response
        }    
    });
}

let removeAllDatabases = (AWS) => {
    var dynamodb = new AWS.DynamoDB();
    dynamodb.listTables({}, function(err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else {
            if(data.TableNames && data.TableNames.length > 0){
            console.log(`Removing tables ${data.TableNames}`); 
            data.TableNames.forEach(tableName => deleteTable(dynamodb, tableName))
            } else {
                console.log(`No dynamo tables in region ${AWS.config.region}`)
            }
        };  
    })
}

module.exports = removeAllDatabases;