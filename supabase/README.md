# Classroom polls

Live polls on the practical pages. Students vote anonymously; the teacher sees
the vote count and decides when everyone sees the results.

## One-time setup (about 10 minutes)

1. Create a free project at <https://supabase.com> (choose region **EU (Frankfurt)**).
2. **SQL Editor → New query**: paste `schema.sql`, change the teacher e-mail if needed, **Run**.
3. **Authentication → Users → Add user**: create your teacher login (same e-mail as in `teachers`).
   Then **Authentication → Sign In / Providers**: turn off *Allow new users to sign up*.
4. **Project Settings → API**: copy the *Project URL* and the *anon public* key into
   `SUPABASE_URL` and `SUPABASE_ANON_KEY` at the top of `utilities/poll.html`.
   (The anon key is meant to be public; the database rules only let students vote.)
5. Re-render the site (`./render.sh`) and push.

## Adding a poll

In any `.qmd` page, the first paragraph is the question and the list items are the options.
The id must be unique across the site.

```markdown
::: {.poll #p2-t1-bmi}
What is the level of measurement of **BMI**?

- Nominal
- Ordinal
- Scale (metric)
:::
```

## In class

- Students open the page normally and click an answer (they can change it until you reveal).
- You open the same page with `?presenter` at the end of the URL, e.g.
  `.../praktikum2/praktikum2.html?presenter`, and log in with the ⚙ gear in the header.
  The browser remembers this, so the gear keeps showing on later visits
  (open any page with `?presenter=off` to remove it).
  Each poll now shows the live count and results, visible only to you.
- **Reveal results** shows the bar chart to everyone; then open the *Task results* panel and discuss.
- **Reset (new round)** starts fresh for the next group; old votes are kept.
- **Votes as CSV** downloads all votes on the page (with round numbers) to share or analyse.

English and German pages use the same ids, so votes from both count together.

