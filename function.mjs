import * as AWS from "@aws-sdk/client-apigatewaymanagementapi";

export const handler = async (event) => {
    // TODO implement
    console.log(JSON.stringify(event));
    const messages =[];
    (event['Records']).forEach(element => {
        const message =  (element['Sns']['Message'])
        console.log(message);
        messages.push(message);
    });
    const URL = "" // give the AWS websocket endpoint 
    const client = new AWS.ApiGatewayManagementApi({endpoint: URL, appVersion: '2018-11-29'});
    const params = {
        ConnectionId: 'QKN7RemyyK4CJoA=', //harcoded connection ID
        Data: JSON.stringify(messages),
    };
    try {
        const response = await client.postToConnection(params);
        console.log('Successfully posted to connection:', response);
        return {
            statusCode: 200,
            body: JSON.stringify('Message sent successfully'),
        };
        } catch (error) {
        console.error('Error posting to connection:', error);
        return {
        statusCode: 500,
        body: JSON.stringify('Error posting message'),
        };
        }

    return response;
  };