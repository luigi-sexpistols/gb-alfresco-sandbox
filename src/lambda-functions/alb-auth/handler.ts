import * as crypto from 'node:crypto'
import { APIGatewayProxyEventV2 } from 'aws-lambda'
import axios from 'axios'
import jwt from 'jsonwebtoken'
import { CognitoJwtVerifier, JwtVerifier } from 'aws-jwt-verify'
import { decomposeUnverifiedJwt } from 'aws-jwt-verify/jwt'
import { assertStringEquals } from 'aws-jwt-verify/assert'
import { Jwk } from 'aws-jwt-verify/jwk'

const userPoolId = process.env.AWS_COGNITO_USER_POOL_ID
const clientId = process.env.AWS_COGNITO_CLIENT_ID
const jwtSigner = process.env.AWS_COGNITO_JWT_SIGNER
const jwtPublicKeyEndpoint = process.env.AWS_COGNITO_JWT_PUBLIC_KEY_ENDPOINT

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
      ...(response.headers ?? {})
    }
  }
}

type GbDataPayload = {
  username: string
  email: string
  phone_number: string
  email_verified: boolean
  phone_number_verified: boolean
}

function filterHeaders(request: Request, regex: RegExp): Record<string, string> {
  const headerNames = Object.keys(request.headers ?? {}).filter(header => regex.test(header)) ?? []

  if (!headerNames || headerNames.length == 0) {
    return {}
  }

  return headerNames.reduce((output, header) => ({ ...output, [header]: request.headers[header] }), {})
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

function verifyDataToken(token: string): Promise<jwt.JwtPayload> {
  if (!userPoolId || !jwtSigner || !clientId) {
    return Promise.reject('Missing value(s) in environment.')
  }

  const { header: { kid } } = decomposeUnverifiedJwt(token)

  if (!kid) {
    return Promise.reject('Could find `kid` in JWT header.')
  }

  const verifier = JwtVerifier.create({
    issuer: CognitoJwtVerifier.parseUserPoolId(userPoolId).issuer,
    audience: null,
    customJwtCheck: ({ header }) => {
      assertStringEquals('ALB ARN', header.signer, jwtSigner)
      assertStringEquals('ALB Client', header.client, clientId)
    }
  })

  return axios
    .get(`${jwtPublicKeyEndpoint}/${kid}`)
    .then(response => response.data)
    .then(key => {
      const jwk = crypto.createPublicKey({ key, format: 'pem', type: 'spki' }).export({ format: 'jwk' })

      verifier.cacheJwks({ keys: [{ ...jwk, kid, alg: 'ES256' } as Jwk] })
    })
    .then(() => verifier.verify(token))
}

export default function (event: Request): Promise<Response> {
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

    return resolve({
      access: authHeaders['x-amzn-oidc-accesstoken'],
      data: authHeaders['x-amzn-oidc-data']
    })
  })
    .then(tokens => Promise.all([
      CognitoJwtVerifier
        .create({ userPoolId, clientId, tokenUse: 'access' })
        .verify(tokens.access)
        .catch(e => {
          console.error('Failed to verify access token.')
          throw e
        }),
      verifyDataToken(tokens.data)
        .catch(e => {
          console.error('Failed to verify data token.')
          throw e
        })
    ]))
    .then(([accessPayload, dataPayload]) => dataPayload as GbDataPayload)
    .then(payload => respond(200, JSON.stringify({ loggedInAs: payload.email })))
    .catch(error => {
      console.error(error)
      return respond(401, JSON.stringify({ error }))
    })
}
