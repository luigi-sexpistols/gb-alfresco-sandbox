import {APIGatewayProxyEventV2} from 'aws-lambda'
import axios from 'axios'
import jwt from 'jsonwebtoken'
import {CognitoJwtVerifier} from 'aws-jwt-verify'

type Request = Pick<APIGatewayProxyEventV2, 'headers' | 'body' | 'isBase64Encoded' | 'queryStringParameters'>

class Response {
  statusCode: number
  body: string
  isBase64Encoded: boolean
  headers: {
    [header: string]: boolean | number | string
  }

  constructor(response: Partial<Response>) {
    this.statusCode = response.statusCode ?? 200
    this.body = response.body ?? ''
    this.isBase64Encoded = response.isBase64Encoded ?? false
    this.headers = {
      'Access-Control-Allow-Origin': '*',
      ...(response.headers ?? {}),
    }
  }
}

type AwsJwt = jwt.Jwt & {
  header?: jwt.JwtHeader & {
    signer: string
  }
}

function filterHeaders(request: Request, regex: RegExp): Record<string, string> {
  const headerNames = Object.keys(request.headers ?? {}).filter(header => regex.test(header)) ?? []

  if (!headerNames || headerNames.length == 0) {
    return {}
  }

  return headerNames.reduce((output, header) => ({...output, [header]: request.headers[header]}), {})
}

function respond(statusCode: number, body: string): Response {
  return new Response({
    statusCode,
    body,
    headers: {
      'Content-Type': 'application/json'
    }
  })
}

function verifyDataToken(token: string, allowedSigner: string): Promise<jwt.JwtPayload> {
  const decoded = (jwt.decode(token, {complete: true}) as AwsJwt) ?? null

  console.debug({decoded})

  if (!decoded?.header?.kid) {
    return Promise.reject('Could find `kid` in JWT header.')
  }

  if (!decoded?.header?.signer || decoded.header.signer !== allowedSigner) {
    console.error(`Invalid signer: ${decoded?.header?.signer ?? '????'}`)
    return Promise.reject('Invalid signer.')
  }

  const url = `${jwtPublicKeyEndpoint}/${decoded.header.kid}`

  console.debug(`Getting public key from "${url}".`)

  return axios
    .get(url)
    .then(response => response.data)
    .then(publicKey => new Promise((resolve, reject) => {
      console.debug(`Got public key for \`kid\` "${decoded.header.kid}"`)
      console.debug(publicKey)

      const callback = (error: Error | null, payload: unknown | undefined) => {
        console.debug({error, payload})

        error ? reject(error) : resolve(payload as jwt.JwtPayload)
      }

      // this matches the docs pretty much exactly in concept, but the signature is invalid with this.
      // @see https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#user-claims-encoding
      jwt.verify(token, publicKey, {algorithms: ['ES256']}, callback)
    }))
}

const userPoolId = process.env.AWS_COGNITO_USER_POOL_ID
const clientId = process.env.AWS_COGNITO_CLIENT_ID
const jwtSigner = process.env.AWS_COGNITO_JWT_SIGNER
const jwtPublicKeyEndpoint = process.env.AWS_COGNITO_JWT_PUBLIC_KEY_ENDPOINT

export default function (event: Request): Promise<Response> {
  const response = new Response({
    headers: {
      'Content-Type': 'application/json',
    },
  })

  if (!userPoolId || !clientId || !jwtSigner || !jwtPublicKeyEndpoint) {
    console.log('Env vars not set.')
    return Promise.resolve(respond(500, ''))
  }

  return new Promise<{ [key: string]: string }>((resolve, reject) => {
    const authHeaders = filterHeaders(event, /^x-amzn-oidc/)

    const requiredHeaders = ['identity', 'accesstoken', 'data']

    if (!requiredHeaders.every(h => Object.keys(authHeaders).includes(`x-amzn-oidc-${h}`))) {
      return reject('Missing auth header(s).')
    }

    console.debug(`Found auth headers: ${JSON.stringify(Object.keys(authHeaders))}`)

    return resolve({
      access: authHeaders['x-amzn-oidc-accesstoken'],
      // remove padding "=" characters from base64-encoded string (these are _not_ valid in JWTs, but AWS does it anyway)
      data: authHeaders['x-amzn-oidc-data'].replace(/=/g, ''),
    })
  })
    .then(tokens => {
      console.info('Verifying tokens.')
      console.debug(tokens)

      return Promise.all([
        CognitoJwtVerifier
          .create({userPoolId, clientId, tokenUse: 'access'})
          .verify(tokens.access).catch(e => {
            console.error('Failed to verify access token.')
            throw e
          }),
        verifyDataToken(tokens.data, jwtSigner).catch(e => {
          console.error('Failed to verify data token.')
          throw e
        }),
      ])
    })
    .then(([accessPayload, dataPayload]) => {
      console.log('Tokens verified!')
      return dataPayload
    })
    .then(dataPayload => {
      console.log('Sending response.')
      return respond(200, JSON.stringify(dataPayload))
    })
    .catch(error => {
      console.error(error)
      return respond(401, JSON.stringify({error}))
    })
}
