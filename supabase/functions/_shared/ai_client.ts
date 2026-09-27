// All AI provider code lives here (ARCHITECTURE.md 9.1). Changing providers
// must only change this file.
//
// Every provider is called through the OpenAI-compatible
// /chat/completions format, which DeepSeek, Together, OpenAI and Gemini all
// accept.
//
// Secrets (Supabase secrets, never in the app):
//   DEEPSEEK_API_KEY        required for chat()
//   DEEPSEEK_MODEL          optional, default "deepseek-flash"
//   DEEPSEEK_THINKING       optional, "enabled" | "disabled" (default disabled)
//   VISION_PROVIDER         deepseek | together | openai | gemini (default deepseek)
//   VISION_MODEL            default "deepseek-flash"
//   VISION_API_KEY          optional, falls back to the provider's own key
//   VISION_FALLBACK_PROVIDER / VISION_FALLBACK_MODEL / VISION_FALLBACK_API_KEY
//                           optional second vision provider tried on failure
//   TOGETHER_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY  provider keys

export type Role = "system" | "user" | "assistant";

export interface ChatMessage {
  role: Role;
  content: string;
}

export interface ChatOptions {
  jsonMode: boolean;
  timeoutMs: number;
  maxTokens?: number;
  temperature?: number;
}

export interface AiClient {
  chat(messages: ChatMessage[], opts: ChatOptions): Promise<string>;
  readHandwriting(
    image: Uint8Array,
    mimeType: string,
    opts: { timeoutMs: number },
  ): Promise<string>;
}

export type AiErrorKind = "config" | "network" | "timeout" | "provider" | "empty";

export class AiError extends Error {
  kind: AiErrorKind;
  status?: number;

  constructor(kind: AiErrorKind, message: string, status?: number) {
    super(message);
    this.name = "AiError";
    this.kind = kind;
    this.status = status;
  }
}

export type EnvReader = (name: string) => string | undefined;

interface ProviderConfig {
  baseUrl: string;
  keyEnv: string;
}

const PROVIDERS: Record<string, ProviderConfig> = {
  deepseek: { baseUrl: "https://api.deepseek.com", keyEnv: "DEEPSEEK_API_KEY" },
  together: { baseUrl: "https://api.together.xyz/v1", keyEnv: "TOGETHER_API_KEY" },
  openai: { baseUrl: "https://api.openai.com/v1", keyEnv: "OPENAI_API_KEY" },
  gemini: {
    baseUrl: "https://generativelanguage.googleapis.com/v1beta/openai",
    keyEnv: "GEMINI_API_KEY",
  },
};

export const HANDWRITING_PROMPT =
  "This is a photo of a handwritten essay. Transcribe exactly as written. " +
  "Do not correct spelling or grammar. Keep the writer's paragraph breaks as " +
  "blank lines. If a word cannot be read, write [unclear]. Do not add any " +
  "comments, headings or explanations. Return only the transcribed text.";

interface Endpoint {
  provider: string;
  url: string;
  apiKey: string;
  model: string;
}

function resolveEndpoint(
  env: EnvReader,
  provider: string,
  model: string | undefined,
  apiKeyOverride: string | undefined,
): Endpoint {
  const config = PROVIDERS[provider];
  if (!config) {
    throw new AiError("config", `Unknown AI provider "${provider}".`);
  }
  const apiKey = apiKeyOverride || env(config.keyEnv);
  if (!apiKey) {
    throw new AiError("config", `Missing API key for provider "${provider}".`);
  }
  if (!model) {
    throw new AiError("config", `Missing model for provider "${provider}".`);
  }
  return {
    provider,
    url: `${config.baseUrl}/chat/completions`,
    apiKey,
    model,
  };
}

type FetchFn = typeof fetch;

/** Converts bytes to base64 without blowing the call stack on large images. */
export function toBase64(bytes: Uint8Array): string {
  let binary = "";
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

function isRetryable(error: unknown): boolean {
  if (error instanceof AiError) {
    return error.kind === "network" ||
      (error.kind === "provider" && (error.status ?? 0) >= 500);
  }
  return false;
}

async function postChatCompletion(
  fetchFn: FetchFn,
  endpoint: Endpoint,
  body: Record<string, unknown>,
  timeoutMs: number,
): Promise<string> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  let response: Response;
  try {
    response = await fetchFn(endpoint.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${endpoint.apiKey}`,
      },
      body: JSON.stringify({ model: endpoint.model, ...body }),
      signal: controller.signal,
    });
  } catch (error) {
    if (controller.signal.aborted) {
      throw new AiError("timeout", `${endpoint.provider} timed out.`);
    }
    throw new AiError("network", `${endpoint.provider} network error: ${error}`);
  } finally {
    clearTimeout(timer);
  }

  if (!response.ok) {
    const detail = await response.text().catch(() => "");
    throw new AiError(
      "provider",
      `${endpoint.provider} returned ${response.status}: ${detail.slice(0, 300)}`,
      response.status,
    );
  }

  const json = await response.json().catch(() => null) as
    | { choices?: { message?: { content?: unknown } }[] }
    | null;
  const content = json?.choices?.[0]?.message?.content;
  if (typeof content !== "string" || content.trim() === "") {
    throw new AiError("empty", `${endpoint.provider} returned an empty answer.`);
  }
  return content;
}

/**
 * Calls the provider with an overall time budget, retrying once on network
 * errors and 5xx responses (ARCHITECTURE.md 9.1).
 */
async function withRetry(
  fetchFn: FetchFn,
  endpoint: Endpoint,
  body: Record<string, unknown>,
  timeoutMs: number,
): Promise<string> {
  const deadline = Date.now() + timeoutMs;
  try {
    return await postChatCompletion(fetchFn, endpoint, body, timeoutMs);
  } catch (error) {
    const remaining = deadline - Date.now();
    if (!isRetryable(error) || remaining < 5000) throw error;
    await new Promise((resolve) => setTimeout(resolve, 500));
    return await postChatCompletion(fetchFn, endpoint, body, remaining - 500);
  }
}

function providerExtras(endpoint: Endpoint, env: EnvReader): Record<string, unknown> {
  if (endpoint.provider !== "deepseek") return {};
  const thinking = env("DEEPSEEK_THINKING") === "enabled" ? "enabled" : "disabled";
  return { thinking: { type: thinking } };
}

export function createAiClient(env: EnvReader, fetchFn: FetchFn = fetch): AiClient {
  return {
    async chat(messages, opts) {
      const endpoint = resolveEndpoint(
        env,
        "deepseek",
        env("DEEPSEEK_MODEL") || "deepseek-flash",
        undefined,
      );
      const body: Record<string, unknown> = {
        messages,
        max_tokens: opts.maxTokens ?? 2048,
        temperature: opts.temperature ?? 0.3,
        stream: false,
        ...providerExtras(endpoint, env),
      };
      if (opts.jsonMode) body.response_format = { type: "json_object" };
      return await withRetry(fetchFn, endpoint, body, opts.timeoutMs);
    },

    async readHandwriting(image, mimeType, opts) {
      const primary = resolveEndpoint(
        env,
        env("VISION_PROVIDER") || "deepseek",
        env("VISION_MODEL") || "deepseek-flash",
        env("VISION_API_KEY"),
      );
      const fallbackProvider = env("VISION_FALLBACK_PROVIDER");
      const dataUrl = `data:${mimeType};base64,${toBase64(image)}`;

      const read = (endpoint: Endpoint, timeoutMs: number) => {
        const imagePart: Record<string, unknown> = { url: dataUrl };
        if (endpoint.provider === "deepseek" || endpoint.provider === "openai") {
          imagePart.detail = "high";
        }
        return withRetry(fetchFn, endpoint, {
          messages: [{
            role: "user",
            content: [
              { type: "text", text: HANDWRITING_PROMPT },
              { type: "image_url", image_url: imagePart },
            ],
          }],
          max_tokens: 4096,
          temperature: 0,
          stream: false,
          ...providerExtras(endpoint, env),
        }, timeoutMs);
      };

      const deadline = Date.now() + opts.timeoutMs;
      try {
        return (await read(primary, opts.timeoutMs)).trim();
      } catch (error) {
        const remaining = deadline - Date.now();
        if (!fallbackProvider || remaining < 8000 ||
          (error instanceof AiError && error.kind === "config")) {
          throw error;
        }
        const fallback = resolveEndpoint(
          env,
          fallbackProvider,
          env("VISION_FALLBACK_MODEL"),
          env("VISION_FALLBACK_API_KEY"),
        );
        return (await read(fallback, remaining)).trim();
      }
    },
  };
}
