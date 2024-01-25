import * as AWS from "@aws-sdk/client-apigatewaymanagementapi";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);





export const getConnectionId =  async (sourceIp) => {
  console.log("INside get Connection ID:" + sourceIp)
    const command = new GetCommand({
      TableName: "websocket-connection",
      Key: {
        clientId: sourceIp,
      },
    });
  
    const response =  await docClient.send(command);
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
};

export const handler = async (event) => {
    // TODO implement
    console.log(JSON.stringify(event));
  let sourceIp
    const messages = event["Records"].map((element) => {
      const message = JSON.parse(element.Sns.Message);
      console.log(message);
      sourceIp = message.sourceIp;
      return message;
    });
    // Considering that we will only have one msg in the topic at a time for now .
    console.log("In handler" + sourceIp)
    const required_connectionId = await getConnectionId(sourceIp);
    console.log(required_connectionId);
    return sendData(required_connectionId, messages);
  
  };