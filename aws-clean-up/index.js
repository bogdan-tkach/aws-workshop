// Load the SDK and UUID
var AWS = require('aws-sdk');

let regions = [
    'eu-north-1',
    'ap-south-1',
    'eu-west-3',
    'eu-west-2',
    'eu-west-1',
    'ap-northeast-2',
    'ap-northeast-1',
    'sa-east-1',
    'ca-central-1',
    'ap-southeast-1',
    'ap-southeast-2',
    'eu-central-1',
    'us-east-1',
    'us-east-2',
    'us-west-1',
    'us-west-2',
]



// AWS.config.region = 'ap-southeast-1';
let params = {};

let deleteCallback = (err, data) => {
    if (err) console.log(err);
    else console.log(`Successfully removed api: ${JSON.stringify(data)}`);
}

let removeAllApis = (apigateway, data) => {
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

regions.forEach(region => {
    console.log(`Running for region ${region}`);
    AWS.config.region = region;
    console.log(AWS.config.region);
    var apigateway = new AWS.APIGateway();
    apigateway.getRestApis(params, function (err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else {
            if (data.items && data.items.length > 0) {
                console.log(`For region ${region} got this apis:` + JSON.stringify(data.items))
                removeAllApis(apigateway, data);
            } else {
                console.log(`No api in region ${region}`)
            }
        }
    });
})

