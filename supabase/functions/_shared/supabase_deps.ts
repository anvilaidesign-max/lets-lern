// Real dependencies for the Edge Functions (Deno runtime only).
// SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are provided by the Edge runtime.

import { createClient } from "npm:@supabase/supabase-js@2";
import type { SupabaseClient } from "npm:@supabase/supabase-js@2";
import { createAiClient } from "./ai_client.ts";
import type { AiClient } from "./ai_client.ts";
import { bearerToken } from "./http.ts";

let admin: SupabaseClient | null = null;

export function adminClient(): SupabaseClient {
  if (!admin) {
    const url = Deno.env.get("SUPABASE_URL");
    const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!url || !key) throw new Error("Supabase environment is missing.");
    admin = createClient(url, key, {
      auth: { persistSession: false, autoRefreshToken: false },
    });
  }
  return admin;
}

export function aiClient(): AiClient {
  return createAiClient((name) => Deno.env.get(name));
}

/** Verifies the caller's JWT and returns their user id, or null. */
export async function getUserId(req: Request): Promise<string | null> {
  const token = bearerToken(req);
  if (!token) return null;
  const { data, error } = await adminClient().auth.getUser(token);
  if (error || !data?.user) return null;
  return data.user.id;
}

export async function incrementUsage(
  userId: string,
  kind: "essay" | "game",
  limit: number,
): Promise<boolean> {
  const { data, error } = await adminClient().rpc("increment_ai_usage", {
    p_user_id: userId,
    p_kind: kind,
    p_limit: limit,
  });
  if (error) throw new Error(`increment_ai_usage failed: ${error.message}`);
  return data === true;
}

export function log(...args: unknown[]): void {
  console.error(...args);
}
