import { type Context, type SQSEvent } from 'aws-lambda'

export const handler = async (event: SQSEvent, context: Context) => {
    console.log('-----context-----\n', JSON.stringify(context, null, 2))
    console.log('-----event-----\n', JSON.stringify(event, null, 2))
}
