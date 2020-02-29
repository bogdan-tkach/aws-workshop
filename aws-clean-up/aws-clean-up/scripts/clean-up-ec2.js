
let terminateInstance = (ec2, instanceId) => {
    let params = {
        "InstanceIds": [
            instanceId
        ]
    };
    ec2.terminateInstances(params, function (err, data) {
        if (err) {
            console.log(`Could not terminate ec2 instance ${instanceId}`);
            console.log(err, err.stack);
        } else {
            console.log(`Instance ${instanceId} terminated`);
            console.log(data);
        }
    });
}

let terminateAllEC2 = (AWS) => {
    let ec2 = new AWS.EC2();
    let params = {};
    ec2.describeInstances(params, function (err, data) {
        if (err) console.log(err, err.stack); // an error occurred
        else {
            if (data.Reservations && data.Reservations.length > 0) {
                let instanceIds = data.Reservations
                    .flatMap(reservations => reservations.Instances)
                    .map(instance => instance.InstanceId);
                console.log(`terminating instances ${instanceIds}`);
                instanceIds.forEach(instanceId => terminateInstance(ec2, instanceId))
            } else {
                console.log(`No ec2 instances in region ${AWS.config.region}`)
            }
        };
    })
}

module.exports = terminateAllEC2;