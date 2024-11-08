import boto3

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
    
    # Format response in JSON
    response = {'visitor_counter': visitor_count}
    return response




        
    


