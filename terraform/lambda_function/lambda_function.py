import boto3
import json

client = boto3.client('dynamodb')
table_name = 'CRCVisitorCounter'
primary_key = 'counter_ID'

def lambda_handler(event, context):
    # Get the key and value
    response = client.get_item(
        TableName = table_name,
        Key={
            primary_key: {
                'S' : 'visitor_counter'
            }
        }
    )
    # Increment the value by one
    visitor_count = int(response['Item']['visitor_count']['N'])
    visitor_count += 1

    # Update the item in DynamoDB
    response = client.update_item(
        TableName = table_name,
        Key={
            primary_key: {
                'S' : 'visitor_counter'
            }
        },
        UpdateExpression="SET visitor_count = :new_count",
        ExpressionAttributeValues={
            ":new_count" : { "N": str(visitor_count)}
        }
    )
    
    # Return the response in the correct format for API Gateway
    return {
        "statusCode": 200,
        "body": json.dumps({"visitor_counter": visitor_count}),
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Content-Type": "application/json"
        }
    }



        
    


