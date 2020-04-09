const AWS = require('aws-sdk');
const express = require('express');
const uuid = require('uuid');
const EMPLOYEES_TABLE = process.env.TABLE;
const DYNAMO_REGION = process.env.DYNAMO_REGION;
AWS.config.update({
    region: DYNAMO_REGION
})
const dynamoDb = new AWS.DynamoDB.DocumentClient();

const router = express.Router();

router.get('/employees', async (req, res) => {
    console.log('get all method called');
        const params = {
            TableName: EMPLOYEES_TABLE
        };
        try {
            let result = await dynamoDb.scan(params).promise();
            console.log('result from dynamo:', result);
            res.json(result != null ? result.Items : {message: 'Response from Dynamo is null'});
        } catch (error) {
            console.log(error);
            res.status(400).json({error: 'Error fetching the employees'});
        }
    }
);


router.get('/employees/:id', async (req, res) => {
    console.log('get by id method called');
    const id = req.params.id;
    const params = {
        TableName: EMPLOYEES_TABLE,
        Key: {
            id
        }
    };
    try {
        let result = await dynamoDb.get(params).promise();
        console.log('result from dynamo:', result);
        res.json(result != null ? result.Item : {message: 'Response from Dynamo is null'});
    } catch (error) {
        console.log(error);
        res.status(400).json({error: 'Error retrieving the employees'});
    }
});

router.post('/employees', async (req, res) => {
    console.log('post method called');
    const name = req.body.name;
    const id = uuid.v4();
    const params = {
        TableName: EMPLOYEES_TABLE,
        Item: {
            id,
            name
        },
    };
    try {
        let result = await dynamoDb.put(params).promise();
        console.log('result from dynamo:', result);
        res.json({id, name});
    } catch (error) {
        console.log(error);
        res.status(400).json({error: 'Could not create Employee'});
    }
});
router.delete('/employees/:id', async (req, res) => {
    console.log('delete method called');
    const id = req.params.id;
    const params = {
        TableName: EMPLOYEES_TABLE,
        Key: {
            id
        }
    };
    try {
        let result = await dynamoDb.delete(params).promise();
        console.log('result from dynamo:', result);
        res.json({success: true});
    } catch (error) {
        console.log(error);
        res.status(400).json({error: 'Could not delete Employee'});
    }
});

router.put('/employees', async (req, res) => {
    console.log('put method called');
    const id = req.body.id;
    const name = req.body.name;
    const params = {
        TableName: EMPLOYEES_TABLE,
        Key: {
            id
        },
        UpdateExpression: 'set #name = :name',
        ExpressionAttributeNames: {'#name': 'name'},
        ExpressionAttributeValues: {':name': name},
        ReturnValues: "ALL_NEW"
    };
    try {
        let result = await dynamoDb.update(params).promise();
        console.log('result from dynamo:', result);
        res.json(result.Attributes);
    } catch (error) {
        console.log(error);
        res.status(400).json({error: 'Could not update Employee'});
    }
});
module.exports = router;