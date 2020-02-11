let deleteCallback = (err, data) => {
    if (err) console.log(err);
    else console.log(`Successfully removed api: ${JSON.stringify(data)}`);
}

let removeAllApisWithTimeout = (apigateway, data) => {
    let timeout = 0;
    if (data.items.length > 0) {
        data.items.forEach(api => {
            setTimeout(() => {
                console.log(`Removing api ${api.name}`);
                apigateway.deleteRestApi({ restApiId: api.id }, deleteCallback);
            }, timeout);
            timeout += 60000;
        })
    }
}
const removeAllApis = (AWS, region) => {
    var apigateway = new AWS.APIGateway();
    apigateway.getRestApis({}, function (err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else {
            if (data.items && data.items.length > 0) {
                console.log(`For region ${AWS.config.region} got this apis:` + JSON.stringify(data.items))
                removeAllApisWithTimeout(apigateway, data);
            } else {
                console.log(`No api in region ${AWS.config.region}`)
            }
        }
    });
}

module.exports = removeAllApis;
