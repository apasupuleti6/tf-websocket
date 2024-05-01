
import { describe, it, expect, beforeEach} from "vitest";
import { handler } from "../disconnect";
import { mockClient } from "aws-sdk-client-mock";
import { DynamoDBDocumentClient,DeleteCommand} from "@aws-sdk/lib-dynamodb";
const ddbMock = mockClient(DynamoDBDocumentClient);
const event = {
    requestContext : {
        connectionId: "test"
    }
};

describe("disconnect testcases", () =>{
    
    beforeEach(() =>{
        ddbMock.reset();
    })
    it.skip("sucessful disconnect",async (event)=>{
        ddbMock
        .on(DeleteCommand)
        .resolves("sucessfully disconnected");

    const result = await handler();
    expect(result).toBe("sucessfully disconnected")

    })
})