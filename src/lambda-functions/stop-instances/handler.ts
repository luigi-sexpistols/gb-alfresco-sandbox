import { EC2Client, StopInstancesCommand } from "@aws-sdk/client-ec2"

const getEnv = (key: string): string | null => process.env?.[key] ?? null

export default function (): Promise<void> {
  const instanceIds = getEnv('INSTANCE_IDS')?.split(',')

  if (!instanceIds) {
    return Promise.reject('Missing INSTANCE_IDS in environment.')
  }

  console.info(`Stopping instances ${JSON.stringify(instanceIds)}`)

  return new EC2Client()
    .send(new StopInstancesCommand({ InstanceIds:  instanceIds }))
    .then(result => {
      result.StoppingInstances
        ?.map(i => `${i.InstanceId}: ${i.CurrentState?.Name ?? 'unknown'}`)
        .map(v => console.info(v))
    })
    .catch(e => {
      console.error(e)

      return Promise.reject("Failed to stop instances.")
    });
}
