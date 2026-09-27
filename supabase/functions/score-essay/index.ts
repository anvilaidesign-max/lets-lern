import { handleScoreEssay } from "../_shared/score_essay.ts";
import type { EssayRow } from "../_shared/score_essay.ts";
import { errorResponse } from "../_shared/http.ts";
import { adminClient, aiClient, getUserId, incrementUsage, log } from "../_shared/supabase_deps.ts";

Deno.serve(async (req) => {
  try {
    return await handleScoreEssay(req, {
      getUserId,
      incrementUsage,
      ai: aiClient(),
      log,
      async getEssay(id) {
        const { data, error } = await adminClient()
          .from("essays")
          .select("id, user_id, prompt, image_path, extracted_text, score_total, score_breakdown, feedback, status")
          .eq("id", id)
          .maybeSingle();
        if (error) throw new Error(`getEssay failed: ${error.message}`);
        return data as EssayRow | null;
      },
      async updateEssay(id, patch) {
        const { error } = await adminClient().from("essays").update(patch).eq("id", id);
        if (error) throw new Error(`updateEssay failed: ${error.message}`);
      },
      async downloadImage(path) {
        const { data, error } = await adminClient().storage.from("essays").download(path);
        if (error || !data) throw new Error(`download failed: ${error?.message}`);
        return {
          bytes: new Uint8Array(await data.arrayBuffer()),
          mimeType: data.type || "image/jpeg",
        };
      },
    });
  } catch (error) {
    log("score-essay crashed", error);
    return errorResponse(500, "server_error", "Something went wrong. Please try again.");
  }
});
