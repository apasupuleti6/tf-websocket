export const handler = async (event) => {
    // TODO implement
    console.log(event)
    const token = event['authorizationToken'];
      let permission = "Deny"
    
    if(token == "aswini"){
        console.log("Inside the if condition");
        permission = "Allow"  
    }
    console.log(permission)
    const response = { 
        "principalId":"aswini_learn",
      "policyDocument": 
      { 
          "Version": "2012-10-17",
              "Statement": 
              [
                  {
                      "Action": "execute-api:Invoke", 
                      "Resource": "*", 
                      "Effect": `${permission}` // Allow OR Deny
                  }
              ] 
      }
  }
  
      console.log(response)
    return response;
  };
  