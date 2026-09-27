import { handleContentUpdates } from "../_shared/content_updates.ts";
import type { ContentRow } from "../_shared/content_updates.ts";
import { errorResponse } from "../_shared/http.ts";
import { adminClient, getUserId, log } from "../_shared/supabase_deps.ts";

Deno.serve(async (req) => {
  try {
    return await handleContentUpdates(req, {
      getUserId,
      now: () => new Date(),
      async fetchUpdates(since, afterId, limit) {
        const { data, error } = await adminClient().rpc("content_updates", {
          p_since: since,
          p_after_id: afterId,
          p_limit: limit,
        });
        if (error) throw new Error(`content_updates failed: ${error.message}`);
        return (data ?? []) as ContentRow[];
      },
    });
  } catch (error) {
    log("get-content-updates crashed", error);
    return errorResponse(500, "server_error", "Something went wrong. Please try again.");
  }
});
