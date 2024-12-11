import {DescribeInstancesCommand, EC2Client, StopInstancesCommand} from '@aws-sdk/client-ec2';

export default function (): Promise<void> {
  const client = new EC2Client()

  const tag_name = JSON.parse(process.env.MATCH ?? '')?.name ?? undefined
  const tag_value = JSON.parse(process.env.MATCH ?? '')?.value ?? undefined

  if (!tag_name || !tag_value) {
    return Promise.reject('Missing or invalid environment variable MATCH.')
  }

  console.info('Finding instances to stop...')

  return client.send(new DescribeInstancesCommand({ Filters: [{ Name: `tag:${tag_name}`, Values: [tag_value] }] }))
    .then(result => {
      return (result.Reservations ?? [])
        .map(r => r.Instances ?? [])
        .flat()
        .filter(i => !!i)
        .map(i => i.InstanceId) as string[]
    })
    .then(instanceIds => {
      console.info(`Stopping instances ${JSON.stringify(instanceIds)}`)

      return client.send(new StopInstancesCommand({ InstanceIds: instanceIds }))
    })
    .then(stopResult => {
      stopResult.StoppingInstances
        ?.map(i => `${i.InstanceId}: ${i.CurrentState?.Name ?? 'unknown'}`)
        .map(v => console.info(v))
    })
    .catch(e => {
      console.error(e)

      return Promise.reject("Failed to stop instances.")
    });
}
