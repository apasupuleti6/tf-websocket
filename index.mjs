import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { PutCommand, DynamoDBDocumentClient } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

export const handler = async (event, context) => {
  const connection_id = event.requestContext.connectionId;
  const sourceIp = event.requestContext.identity.sourceIp;
  console.log("The event is: "+ JSON.stringify(event));
  const command = new PutCommand({
    TableName: "websocket-connection",
    Item: {
      clientId: sourceIp,
      connectionId: connection_id
    },
  });

  const response = await docClient.send(command);
  // console.log("came out of successful creation of table insert");
  console.log(response);
  const return_response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda! The connection Id is: '+ connection_id),
  };
  return return_response;
};

