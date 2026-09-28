import { handleDeleteAccount } from "../_shared/delete_account.ts";
import { errorResponse } from "../_shared/http.ts";
import { adminClient, getUserId, log } from "../_shared/supabase_deps.ts";

Deno.serve(async (req) => {
  try {
    return await handleDeleteAccount(req, {
      getUserId,
      log,
      async listEssayPhotos(userId) {
        const paths: string[] = [];
        for (let offset = 0; ; offset += 100) {
          const { data, error } = await adminClient().storage.from("essays").list(userId, { limit: 100, offset });
          if (error) throw new Error(`list failed: ${error.message}`);
          paths.push(...(data ?? []).map((f) => `${userId}/${f.name}`));
          if (!data || data.length < 100) break;
        }
        return paths;
      },
      async removeEssayPhotos(paths) {
        const { error } = await adminClient().storage.from("essays").remove(paths);
        if (error) throw new Error(`remove failed: ${error.message}`);
      },
      async deleteUser(userId) {
        const { error } = await adminClient().auth.admin.deleteUser(userId);
        if (error) throw new Error(`deleteUser failed: ${error.message}`);
      },
    });
  } catch (error) {
    log("delete-account crashed", error);
    return errorResponse(500, "server_error", "Something went wrong. Please try again.");
  }
});
