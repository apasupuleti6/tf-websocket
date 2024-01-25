import { mockClient } from "aws-sdk-client-mock";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import { handler, getConnectionId, sendData } from "./function";
import { describe, it, beforeEach,expect} from "vitest";



const ddbMock = mockClient(DynamoDBDocumentClient);

describe("getConnectionID from Dynamo DB", () => {
  beforeEach(() => {
    ddbMock.reset();
  });


  it("should get connectionId from the DynamoDB", async () => {
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
      })
      .on(GetCommand, {
        TableName: "websocket-connection",
        Key: { clientId: "167.89.232" },
      })
      .resolves({
        Item: { clientId: "167.89.232", connectionId: "second_connection_id" },
      });
    const result = await getConnectionId('167.89.232')
    expect(result).toBe("second_connection_id");
  });
});
