import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, DeleteCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);


export const handler = async (event) => {
  const connection_id = event.requestContext.connectionId;
  const command = new DeleteCommand({
    TableName: "websocket-connection",
    Key: {
      connectionId: connection_id,
    },
  });

  const response = await docClient.send(command);
  console.log(response);
  return response;
};

