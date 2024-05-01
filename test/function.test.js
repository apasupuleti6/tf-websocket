import { mockClient } from "aws-sdk-client-mock";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import { handler, getConnectionId, sendData } from "./function";
import { describe, it, beforeEach, expect } from "vitest";
import {
  ApiGatewayManagementApi,
  PostToConnectionCommand,
} from "@aws-sdk/client-apigatewaymanagementapi";

const ddbMock = mockClient(DynamoDBDocumentClient);
const clientMock = mockClient(ApiGatewayManagementApi);
const testResponse = {
  $metadata: {
    httpStatusCode: 200,
    requestId: "92ead1b8-3f87-4914-b0ed-0542c36544c2",
    extendedRequestId: undefined,
    cfId: undefined,
    attempts: 1,
    totalRetryDelay: 0,
  },
};

const inputRecords = {
  Records: [
    {
      Sns: {
        Message: {
          sourceIp: "167.89.777",
        },
      },
    },
  ],
};

// describe("getConnectionID from Dynamo DB", () => {
//   beforeEach(() => {
//     ddbMock.reset();
//   });

//   it("should get connectionId from the DynamoDB", async () => {
//     ddbMock
//       .on(GetCommand)
//       .resolves({
//         Item: undefined,
//       })
//       .on(GetCommand, {
//         TableName: "websocket-connection",
//         Key: { clientId: "167.89.777" },
//       })
//       .resolves({
//         Item: { connectionId: "first_connection_id", clientId: "167.89.777" },
//       })
//       .on(GetCommand, {
//         TableName: "websocket-connection",
//         Key: { clientId: "167.89.232" },
//       })
//       .resolves({
//         Item: { clientId: "167.89.232", connectionId: "second_connection_id" },
//       });
//     const result = await getConnectionId("167.89.232");
//     expect(result).toBe("second_connection_id");
//   });
// });

describe("mock full", () => {
  beforeEach(() => {
    ddbMock.reset();
  });

  it("first try", async () => {
    clientMock.on(PostToConnectionCommand).resolves(testResponse);
    ddbMock
      .on(GetCommand)
      .resolves({
        Item: undefined,
      })
      .on(GetCommand, {
        TableName: "websocket-connection",
        Key: { clientId: "167.89.777" },
      })
      .resolves({
        Item: { connectionId: "first_connection_id", clientId: "167.89.777" },
      });
    
    let fn = async () =>{  handler(inputRecords)};
      //qgetConnectionId("167.89.232")};
     expect(fn).rejects.toThrow();
    // Assert
    // expect(result.statusCode).toBe(200);
  });
});
