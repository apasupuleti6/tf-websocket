locals {
  tablename = "websocket-connection"
}


resource "aws_dynamodb_table" "connection-dynamodb-table" {
  name           = local.tablename
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "clientId"
  /*
creating a table with two attributes:[ clientId, connectionId ]. Defining both the attrubutes as strings
*/
  attribute {
    name = "clientId"
    type = "S"
  }

  attribute {
    name = "connectionId"
    type = "S"
  }


  # global_secondary_index {
  #   name               = "clientId-index"
  #   hash_key           = "clientId"
  #   range_key          = "connectionId"
  #   write_capacity     = 10
  #   read_capacity      = 10
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["connectionId"]
  # }

  global_secondary_index {
    name               = "connectionId-index"
    hash_key           = "connectionId"
    range_key          = "clientId"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["clientId"]
  }

  tags = {
    Name        = "dynamodb-table-websocket-connection"
    Environment = "dev"
  }
}

