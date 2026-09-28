// delete-account: permanently deletes the caller's account and all their
// data (Google Play account deletion requirement).
//
// Deleting the auth user cascades to profiles, progress, daily activity,
// essays, AI game sessions, AI usage, content reports and chapter progress.
// Essay photos in Storage are removed first.

import { corsHeaders, errorResponse, jsonResponse, readJsonBody } from "./http.ts";

export interface DeleteAccountDeps {
  getUserId(req: Request): Promise<string | null>;
  listEssayPhotos(userId: string): Promise<string[]>;
  removeEssayPhotos(paths: string[]): Promise<void>;
  deleteUser(userId: string): Promise<void>;
  log?: (...args: unknown[]) => void;
}

export async function handleDeleteAccount(req: Request, deps: DeleteAccountDeps): Promise<Response> {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return errorResponse(405, "method_not_allowed", "Use POST.");

  const userId = await deps.getUserId(req);
  if (!userId) return errorResponse(401, "unauthorized", "Please sign in again.");

  // An explicit confirmation guards against accidental calls.
  const body = await readJsonBody(req);
  if (body?.confirm !== "DELETE") {
    return errorResponse(400, "confirmation_required", "Send {\"confirm\": \"DELETE\"} to delete the account.");
  }

  try {
    const photos = await deps.listEssayPhotos(userId);
    if (photos.length > 0) await deps.removeEssayPhotos(photos);
  } catch (error) {
    deps.log?.("essay photo cleanup failed", error);
    return errorResponse(500, "server_error", "We could not delete your essay photos. Please try again.");
  }

  try {
    await deps.deleteUser(userId);
  } catch (error) {
    deps.log?.("deleteUser failed", error);
    return errorResponse(500, "server_error", "We could not delete your account. Please try again.");
  }

  return jsonResponse({ deleted: true });
}
