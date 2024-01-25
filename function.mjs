import * as AWS from "@aws-sdk/client-apigatewaymanagementapi";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event) => {
  // TODO implement
  console.log(JSON.stringify(event));

  const messages = event["Records"].map((element) => {
    const message = element["Sns"]["Message"];
    console.log(message);
    sourceIp = message.sourceIp;
    return message;
  });
  // Considering that we will only have one msg in the topic at a time for now .
  const required_connectionId = getConnectionId(sourceIp);

  return sendData(required_connectionId, messages);
  /*
    ********* code to use map ***********

    messages = (event['Records']).map(element => {
        const message = element['Sns']['Message'];
        console.log(message);
        retu
        rn message;
    });
     */
};

export const getConnectionId = async (sourceIp) => {
  const command = new GetCommand({
    TableName: "websocket-connection",
    Key: {
      clientId: sourceIp,
    },
  });

  const response = await docClient.send(command);

  console.log(response);
  const required_connectionId = response["Item"]["connectionId"];
  console.log(required_connectionId);
  return required_connectionId;
};

export const sendData = async (connectionId, messages) => {
  const URL = ""; // give the AWS websocket endpoint
  const client = new AWS.ApiGatewayManagementApi({
    endpoint: URL,
    appVersion: "2018-11-29",
  });
  const params = {
    ConnectionId: connectionId,
    Data: JSON.stringify(messages),
  };
  try {
    const response = await client.postToConnection(params);
    console.log("Successfully posted to connection:", response);
    return {
      statusCode: 200,
      body: JSON.stringify("Message sent successfully"),
    };
  } catch (error) {
    console.error("Error posting to connection:", error);
    return {
      statusCode: 500,
      body: JSON.stringify("Error posting message"),
    };
  }

  return response;
};
