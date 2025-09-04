# Agent Collaboration Guidelines

## Core Principles
-   **Work Slow and Steady:** Prioritize a high success rate over speed. Propose small, manageable plans and ensure each step is correct before moving on.
-   **Strict Adherence to Guidelines:** All guidelines in this document must be followed without deviation, unless explicitly instructed otherwise by the user for a specific circumstance.

## Workflow
1.  **Branching:** A new, descriptive feature branch will be created for every new task (e.g., `feat/player-health`, `fix/login-error`). The `submit` tool's `branch_name` parameter must be used.
2.  **Propose & Approve:** Before starting any new task, propose a clear, step-by-step plan. Wait for the user's explicit "proceed" or "ok" command before starting work.
3.  **Set Plan & Record Approval:** Once approval is given, formalize the plan using the `set_plan` tool and record the approval using the `record_user_approval_for_plan` tool.
4.  **Atomic Commits:** Each commit must be small and focused on a single logical change. Do not bundle unrelated features, documentation, or fixes.
5.  **Submission Process:** Before submitting, all changes must be reviewed using `request_code_review`. After a successful review, the `VERSION` file must be incremented and `record_memory` must be called.

## Collaboration Model
-   **The User as "Eyes and Hands":** For tasks that require actions inside Roblox Studio (e.g., checking visual layouts, creating parts), you can and should instruct the user to act as your "eyes and hands."
-   **Proactive Investigation:** You can proactively ask the user to check what is happening in the Roblox environment to help with debugging or verification. Provide clear, step-by-step instructions for these requests.

---
## Key Learnings & Common Pitfalls

This section documents critical learnings from past mistakes to ensure they are not repeated.

1.  **Do Not Assume Tool Behavior:** If you are unsure how a tool (`submit`, `reset_all`, etc.) works, **ask the user for clarification first**. Do not assume its behavior.
2.  **State Management is Critical:** The local workspace can get out of sync with the remote repository. The `reset_all()` command reverts to the *initial* commit of the project, not the latest version on the `main` branch. It erases all subsequent work and should only be used as a last resort at the beginning of a major process reset.
3.  **The `submit` Tool and Branching:** The `submit` tool may not create new branches as expected. All work may be committed to a single branch. Be mindful of this and communicate clearly with the user about which branch you are on.
4.  **The `message_user` Tool is Unreliable:** The chat tool can fail silently or with errors. If direct communication fails repeatedly, use the established workaround: create a `.md` file with the communication and `submit` it for the user to read.
5.  **Git Workflow is Essential:** The user needs to `git fetch` and `git checkout <branch-name>` to see new branches. Be prepared to guide them through this process.
