
import { describe, it, expect, beforeEach} from "vitest";
import { handler } from "../disconnect";
import { mockClient } from "aws-sdk-client-mock";
import { DynamoDBDocumentClient,DeleteCommand} from "@aws-sdk/lib-dynamodb";
const ddbMock = mockClient(DynamoDBDocumentClient);

describe("disconnect testcases", () =>{
    beforeEach(() =>{
        ddbMock.reset();
    })
    it("sucessful disconnect",async ()=>{
        ddbMock
        .on(DeleteCommand)
        .resolves("sucessfully disconnected");

    const result = await handler();
    expect(result).toBe("sucessfully disconnected")

    })
})