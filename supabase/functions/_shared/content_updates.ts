// get-content-updates (ARCHITECTURE.md 7.2).
// Request:  { since?: timestamp, after_id?: uuid, limit?: int, include_unverified?: bool }
// Response: { items, next_cursor: { since, after_id } | null, server_time }
//
// Uses keyset pagination on (updated_at, id) so no item is skipped when many
// rows share the same updated_at. Items that are inactive (or unverified when
// the user did not opt in) are returned as tombstones { id, is_active: false }
// so the app removes them locally.

import { corsHeaders, errorResponse, isUuid, jsonResponse, readJsonBody } from "./http.ts";

export const MAX_LIMIT = 500;
export const EPOCH = "1970-01-01T00:00:00+00:00";
export const ZERO_UUID = "00000000-0000-0000-0000-000000000000";
/** server_time is moved back a little so rows committed late are not missed. */
export const SAFETY_MARGIN_MS = 60_000;

export interface ContentRow {
  id: string;
  updated_at: string;
  is_active: boolean;
  verified: boolean;
  [key: string]: unknown;
}

export interface ContentUpdatesDeps {
  getUserId(req: Request): Promise<string | null>;
  fetchUpdates(since: string, afterId: string, limit: number): Promise<ContentRow[]>;
  now(): Date;
}

const PUBLIC_FIELDS = [
  "id", "topic_code", "type", "title", "body", "statement", "is_true",
  "correct_answer", "explanation", "term", "translation", "example_sentence",
  "difficulty", "source_name", "source_url", "verified", "in_offline_pack",
  "is_active", "created_at", "updated_at",
];

export async function handleContentUpdates(req: Request, deps: ContentUpdatesDeps): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return errorResponse(405, "method_not_allowed", "Use POST.");

  const userId = await deps.getUserId(req);
  if (!userId) return errorResponse(401, "unauthorized", "Please sign in again.");

  const body = (await readJsonBody(req)) ?? {};

  let since = EPOCH;
  if (typeof body.since === "string" && body.since !== "") {
    if (Number.isNaN(Date.parse(body.since))) {
      return errorResponse(400, "bad_request", "since must be a timestamp.");
    }
    since = body.since;
  }
  const afterId = isUuid(body.after_id) ? body.after_id : ZERO_UUID;
  const requested = typeof body.limit === "number" ? Math.floor(body.limit) : MAX_LIMIT;
  const limit = Math.min(Math.max(requested, 1), MAX_LIMIT);
  const includeUnverified = body.include_unverified === true;

  const serverTime = new Date(deps.now().getTime() - SAFETY_MARGIN_MS).toISOString();
  const rows = await deps.fetchUpdates(since, afterId, limit);

  const items = rows.map((row) => {
    if (!row.is_active || (!row.verified && !includeUnverified)) {
      return { id: row.id, is_active: false, updated_at: row.updated_at };
    }
    const item: Record<string, unknown> = {};
    for (const field of PUBLIC_FIELDS) item[field] = row[field] ?? null;
    return item;
  });

  const last = rows[rows.length - 1];
  const nextCursor = rows.length === limit && last
    ? { since: last.updated_at, after_id: last.id }
    : null;

  return jsonResponse({ items, next_cursor: nextCursor, server_time: serverTime });
}
