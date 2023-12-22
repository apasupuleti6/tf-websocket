import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event, context) => {
  console.log("The event is: "+ JSON.stringify(event));
  const command = new PutCommand({
    TableName: "websocket-connection",
    Item: {
      clientId:"testClientInsert",
      connectionId: event['requestContext']['connectionId']
    },
  });

  const response = await docClient.send(command);
  console.log("came out of successful creation of table insert");
  console.log(response);
  const return_response = {
    statusCode : 200
  };
  return JSON.stringify(return_response);
};
