---
title: "Callout & Contributions Preview"
draft: true
date: "2025-01-01"
slug: "callout-preview"
author:
  - name: Beatriz Milz
    directory_id: "beatriz-milz"
    contributions: [a, b]
  - name: Haydee Svab
    directory_id: "haydee-svab"
    contributions: [a, c]
  - name: Tatyane Paz Dominguez
    contributions: [c]
editorial:
  - name: Athanasia Mo Mowinckel
    directory_id: "athanasia-mo-mowinckel"
    contributions: [d]
contributions:
  a: "Wrote the original post"
  b: "Organized community events"
  c: "Conducted diversity survey"
  d: "Edited for publication"
---

## Default callouts

{{< callout type="tip" >}}
This is a **tip** callout. Great for helpful suggestions and best practices.
{{< /callout >}}

{{< callout type="info" >}}
This is an **info** callout. Use it for supplementary information or context.
{{< /callout >}}

{{< callout type="warning" >}}
This is a **warning** callout. Highlights something the reader should be cautious about.
{{< /callout >}}

{{< callout type="danger" >}}
This is a **danger** callout. For critical information about breaking changes or destructive actions.
{{< /callout >}}

{{< callout type="note" >}}
This is a **note** callout. A neutral aside or footnote.
{{< /callout >}}

## Custom titles

{{< callout type="tip" title="Pro tip" >}}
You can override the default title with any text you like.
{{< /callout >}}

{{< callout type="info" title="Did you know?" >}}
Callouts support full **markdown** including [links](https://rladies.org), `inline code`, and lists:

- Item one
- Item two
{{< /callout >}}

## Custom icon

{{< callout type="warning" icon="fa-solid fa-heart" title="Custom icon" >}}
You can also override the icon with any Font Awesome class.
{{< /callout >}}

