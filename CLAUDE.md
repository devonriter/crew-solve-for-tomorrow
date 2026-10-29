# Riter CREW: Solve for Tomorrow build

Instructions for the AI that builds this project. Read all of this before changing anything.

## Who is who

- **The students** (a high school CREW class in Detroit) are the product team. They talk to the partners, decide what to build, write feature requests, and test previews. They work in free ChatGPT on school Chromebooks. They do not have GitHub access and cannot run code locally.
- **Devon (the teacher)** carries requests from the students to you and carries previews back. Every request reaches you through him.
- **You** build. One request at a time, on its own branch, opened as a pull request so a preview deploys. Devon merges.

The students' shared memory is the Crew Brain, a published Google Doc. The request and test formats below match the ones in it.

## What we are building

Not chosen yet. The crew's focus is **helping people in Detroit get jobs**, working with two partners: Better Way Detroit and Detroit Rescue Mission Ministries. The project is an entry in Samsung Solve for Tomorrow (2026-27). The application (due Nov 23, 2026) is five written questions; semifinalists make a 3-minute video (early 2027); finalists present live (spring 2027).

Until a product is chosen, this repo is a plain static site (`index.html`) so the request, build, preview, test loop can be practiced. When the product is chosen, pick the simplest stack that does the job, say why in the PR, and keep it deployable on Vercel.

## How a request arrives

Devon pastes a Feature Request in this shape:

```
Feature Request
Title:
Who it is for:
What it should do:
How we will know it works (what we will check in the preview):
Out of scope (what it should NOT do):
Requested by (first names):
```

If a request is unclear or contradicts an earlier decision, do not guess. Build nothing and write back the one question that would settle it.

## How you deliver

1. Branch off `main`, named after the request title.
2. Build the smallest version that passes "How we will know it works."
3. Open a pull request. In the body, write for the students, not for engineers:
   - What changed, in two or three plain sentences.
   - How to test it: the exact steps to try in the preview, one per line, matching their checklist.
   - Anything you chose that they should know about or might want to change.
4. Give Devon the preview link.

Students send back a Test Report:

```
Test Report
Feature:
What we checked:
What worked:
What did not work (what we did, what we expected, what happened):
Decision: ship it / fix it / rethink it
```

"Fix it" comes back as a follow-up on the same branch. "Ship it" means Devon merges.

## Hard rules

- **No real client data, ever.** The partners serve people in recovery, reentry and homelessness. All examples, seed data and test accounts are invented. Do not build anything that stores real client information until Devon says a partner has approved how it is stored, and even then students must not be able to see it.
- **No student last names, photos, emails or other personal details** in code, content, commits or pages. First names only, and only where the students asked for them.
- **Everything here may be public.** Preview links are shared with students on school Chromebooks. Write nothing a stranger should not read.
- **Keep it simple enough to explain.** Students must be able to understand what each feature does from the PR description. Prefer fewer files, fewer dependencies, plain HTML/CSS/JS until the product needs more.
- **Accessible and mobile-first.** Partners' clients will mostly use phones. Readable text, large tap targets, works without a login unless the feature needs one.
- **No third-party integrations (Facebook, Instagram, payment, messaging, etc.) without Devon's explicit go-ahead in the request.** They need accounts, approvals and data agreements the students do not control.
- This repo is separate from The Impact Classroom. Never reference, copy from, or connect to that platform or its data.
