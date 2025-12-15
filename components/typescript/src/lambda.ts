/**
 * AWS Lambda handler for Voice Sandwich Agent
 *
 * This wraps the WebSocket logic to work with API Gateway WebSocket API
 */

import { config } from "dotenv";
import { fileURLToPath } from "node:url";
import path from "node:path";
import { APIGatewayProxyWebsocketEventV2, APIGatewayProxyResultV2 } from "aws-lambda";

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
config({ path: path.join(__dirname, "../.env") });

// Import Secrets Manager for API keys
import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

let cachedSecrets: Record<string, string> | null = null;

async function getSecrets(): Promise<Record<string, string>> {
  if (cachedSecrets) {
    return cachedSecrets;
  }

  const secretsArn = process.env.SECRETS_ARN;
  if (!secretsArn) {
    throw new Error("SECRETS_ARN environment variable not set");
  }

  const client = new SecretsManagerClient({ region: process.env.AWS_REGION });
  const command = new GetSecretValueCommand({ SecretId: secretsArn });
  const response = await client.send(command);

  if (!response.SecretString) {
    throw new Error("Secret value is empty");
  }

  cachedSecrets = JSON.parse(response.SecretString);

  // Set as environment variables
  Object.entries(cachedSecrets).forEach(([key, value]) => {
    process.env[key] = value;
  });

  return cachedSecrets;
}

export const handler = async (
  event: APIGatewayProxyWebsocketEventV2
): Promise<APIGatewayProxyResultV2> => {
  console.log("Event:", JSON.stringify(event, null, 2));

  try {
    // Load secrets on first invocation
    await getSecrets();

    const { routeKey, connectionId, requestContext } = event;

    switch (routeKey) {
      case "$connect":
        console.log(`Client connected: ${connectionId}`);
        return { statusCode: 200, body: "Connected" };

      case "$disconnect":
        console.log(`Client disconnected: ${connectionId}`);
        return { statusCode: 200, body: "Disconnected" };

      case "$default":
        // Handle WebSocket messages
        // TODO: Import and use the voice agent logic here
        console.log(`Received message from ${connectionId}`);
        return { statusCode: 200, body: "Message received" };

      default:
        return { statusCode: 400, body: "Unsupported route" };
    }
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal server error" }),
    };
  }
};
