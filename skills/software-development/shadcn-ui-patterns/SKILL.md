---
name: shadcn-ui-patterns
description: Apply shadcn rules when writing components, forms, chat UI.
version: 0.2.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [shadcn, react, tailwind, components, patterns]
    related_skills: [shadcn-ui-bootstrap]
---

# shadcn/ui Patterns

Apply the critical shadcn/ui rules when writing components, forms, chat UIs, or pages in any project that uses `shadcn`. Use when editing `.tsx`/`.jsx` files in a project with `components.json`, adding components with `npx shadcn@latest add`, or reviewing code that uses shadcn primitives. Don't use for: bootstrapping a new project (load `shadcn-ui-bootstrap`), styling opinions outside shadcn's system, or non-shadcn Tailwind code.

## When to Use

- Adding a new component (form, dialog, sheet, table, sidebar, chat bubble) to a shadcn project.
- Refactoring or reviewing existing shadcn code that may violate the rules.
- Migrating from raw `<div>` markup to shadcn composition.
- Loading chat/conversation UI for ANC reminder, counseling, or messaging features.

## Don't Use For

- Initializing a fresh project → `shadcn-ui-bootstrap`.
- Plain Tailwind without shadcn.
- Backend API code, database, auth.

## Prerequisites

- A shadcn project exists (has `components.json`). Refresh project context first if unsure: `terminal(command="npx shadcn@latest info --json", workdir="<project>")`.
- Read the key fields the upstream skill requires: `aliases` (use `@/` or the project's actual prefix), `isRSC` (need `"use client"` for hooks/events), `tailwindVersion` (v3 = `tailwind.config.js`, v4 = `@theme inline` in CSS), `base` (radix vs base — affects `asChild` vs `render`), `iconLibrary` (lucide vs hugeicons vs tabler), `tailwindCssFile`, `framework`.

## Workflow

1. **Check what's installed.** Read `npx shadcn@latest info --json` → `components` array. Don't import a component that hasn't been added. Don't re-add one that's installed.
2. **Get docs and example URLs** for the components you plan to compose. `terminal(command="npx shadcn@latest docs <comp1> <comp2>")`. Fetch the URLs with `web_extract` to see real usage patterns — never guess the API.
3. **Plan the composition first.** Pick the smallest set of shadcn primitives that satisfy the need (per the upstream Component Selection table). Settings page = `Tabs` + `Card` + form controls. Dashboard = `Sidebar` + `Card` + `Chart` + `Table`. Chat = `MessageScroller` + `Message` + `Bubble` + `Attachment`/`Marker`.
4. **Install missing components** with `terminal(command="npx shadcn@latest add <comp>", workdir="<project>")`. After install, **read the added files** and verify per upstream rule 7: missing sub-components (e.g. `SelectItem` without `SelectGroup`), wrong imports, bad composition. Fix before moving on.
5. **Write the code** following the Critical Rules below.
6. **Verify** the file imports use the project's alias from `aliases.components` (not hardcoded `@/components` if the project uses something else) and the icon imports match `iconLibrary`.

## Critical Rules (always enforced)

These mirror upstream `shadcn`'s enforced rules. Each one is a common mistake — if you find yourself doing it, stop.

### Styling & Tailwind

- **`className` for layout, not styling.** Never override component colors or typography. Use variants (`variant="outline"`, `size="sm"`).
- **No `space-x-*` / `space-y-*`.** Use `flex` with `gap-*`. For vertical stacks: `flex flex-col gap-*`.
- **Equal width/height → `size-*`.** `size-10`, not `w-10 h-10`.
- **Use `truncate` shorthand.** Not the manual `overflow-hidden text-ellipsis whitespace-nowrap` triplet.
- **No manual `dark:` color overrides.** Use semantic tokens: `bg-background`, `text-muted-foreground`, `border-input`. Define new tokens in the project's `tailwindCssFile`.
- **`cn()` for conditional classes.** Don't write template-literal ternaries by hand.
- **No manual `z-index` on overlay components.** `Dialog`, `Sheet`, `Popover`, `Drawer`, `DropdownMenu` handle their own stacking.

### Forms & Inputs

- **Forms use `FieldGroup` + `Field`.** Never raw `<div className="space-y-*">` or `grid gap-*` for form layout.
- **`InputGroup` uses `InputGroupInput` / `InputGroupTextarea`.** Never raw `Input`/`Textarea` inside `InputGroup`.
- **Buttons inside inputs use `InputGroup` + `InputGroupAddon`.**
- **Connected buttons use `ButtonGroup`.** Never manual negative margins or ad-hoc flex border hacks.
- **Native form controls:** use `NativeSelect` when native browser picker behavior or ultra-lightweight dropdowns are needed while maintaining design system styling.
- **Multi-step forms:** use `Questionnaire` for multi-step survey/intake flows (single-choice, multiple-choice, freeform, skippable questions) instead of custom wizard state machines.
- **Option sets (2–7 choices) use `ToggleGroup`.** Don't loop `Button` with manual active state.
- **`FieldSet` + `FieldLegend`** for grouping related checkboxes/radios. Don't use a div with a heading.
- **Validation:** `data-invalid` on `Field`, `aria-invalid` on the control. For disabled: `data-disabled` on `Field`, `disabled` on the control. Pair them.

### Component Composition

- **Items always inside their Group.** `SelectItem` → `SelectGroup`. `DropdownMenuItem` → `DropdownMenuGroup`. `CommandItem` → `CommandGroup`. Radio items need `RadioGroup`. Tabs triggers need `TabsList`.
- **Custom triggers:** use `asChild` (Radix) or `render` (Base UI) — check `base` from project info. Never nest a `<button>` inside another `<button>`.
- **Dialog / Sheet / Drawer always need a Title.** `DialogTitle`, `SheetTitle`, `DrawerTitle` are required for accessibility. Use `className="sr-only"` if visually hidden.
- **Use full Card composition.** `CardHeader` / `CardTitle` / `CardDescription` / `CardContent` / `CardFooter`. Don't dump everything in `CardContent`.
- **Button has no `isPending` / `isLoading` prop.** Compose with `Spinner` + `data-icon="inline-start"` + `disabled`.
- **Avatar always needs `AvatarFallback`.** Required when the image fails to load.

### Prefer Components Over Custom Markup

- **Callouts → `Alert`.** Not a styled `<div>`.
- **Empty states → `Empty`.** Not a hand-built empty-state markup.
- **Media / list items → `Item`.** Use for displaying rich content cards/rows with media, title, description, and actions instead of custom flex cards.
- **Keyboard shortcuts → `Kbd`.** Render shortcut hints via `Kbd` instead of manual `<kbd>` tags or styled spans.
- **Bi-directional layout → `Direction`.** Wrap with `Direction` provider for RTL/LTR text direction requirements instead of manual `dir` attributes across DOM nodes.
- **Toast:** `toast` from the `toast` component for Base UI; `toast()` from `sonner` for Radix / React Aria. Don't import both.
- **`<hr>` or `border-t` divs → `Separator`.**
- **Loading placeholders → `Skeleton`.** No custom `animate-pulse` divs.
- **Status pills → `Badge`** with variant (`default`, `secondary`, `outline`, `destructive`). Never a styled span with raw colors.

### Icons

- **Icons inside `Button` use `data-icon`.** `data-icon="inline-start"` or `data-icon="inline-end"`. The component handles sizing.
- **No sizing classes on icons inside components.** No `size-4` / `w-4 h-4` on icons that are children of `Button`, `Input`, etc.
- **Pass icons as objects, not string keys.** `icon={CheckIcon}`, not `icon="check"` with a lookup.

### Chat & Messaging

- **Conversations compose chat primitives.** Rows = `Message`, surfaces = `Bubble`. Never hand-rolled bubble `<div>`s or raw scroll containers.
- **`MessageScroller` owns scroll behavior.** Streaming follow, anchoring, and jump-to-latest (`MessageScrollerButton`) are built in. Don't write `useStickToBottom` / `ResizeObserver` hooks.
- **Attachments → `Attachment`.** System notes and dividers → `Marker`. Not `Item` cards, not `Separator` + label.

## Key Patterns (copy-paste-ready)

```tsx
// Form layout — FieldGroup + Field, not div + Label.
<FieldGroup>
  <Field>
    <FieldLabel htmlFor="email">Email</FieldLabel>
    <Input id="email" />
  </Field>
</FieldGroup>

// Validation — data-invalid on Field, aria-invalid on the control.
<Field data-invalid>
  <FieldLabel>Email</FieldLabel>
  <Input aria-invalid />
  <FieldDescription>Invalid email.</FieldDescription>
</Field>

// Icon in button — data-icon, no sizing classes.
<Button>
  <SearchIcon data-icon="inline-start" />
  Search
</Button>

// Spacing — gap-*, not space-y-*.
<div className="flex flex-col gap-4">   // correct
<div className="space-y-4">            // wrong

// Equal dimensions — size-*, not w-* h-*.
<Avatar className="size-10">    // correct
<Avatar className="w-10 h-10">  // wrong

// Status — Badge variant, not raw color.
<Badge variant="secondary">+20.1%</Badge>            // correct
<span className="text-emerald-600">+20.1%</span>     // wrong
```

## Component Selection (quick lookup)

| Need                       | Use                                                                                                  |
| -------------------------- | ---------------------------------------------------------------------------------------------------- |
| Button / action            | `Button` (variant: `default`, `outline`, `ghost`, `destructive`, `secondary`, `link`), `ButtonGroup` |
| Form inputs                | `Input`, `Select`, `NativeSelect`, `Combobox`, `Switch`, `Checkbox`, `RadioGroup`, `Textarea`, `InputOTP`, `Slider`, `Field`, `InputGroup` |
| Multi-step questionnaire   | `Questionnaire` (single-choice, multiple-choice, freeform, skippable questions)                      |
| Toggle 2–5 options         | `ToggleGroup` + `ToggleGroupItem`, `Toggle`                                                          |
| Data display               | `Table`, `DataTable`, `Card`, `Badge`, `Avatar`, `Item`, `Kbd`                                        |
| Navigation                 | `Sidebar`, `NavigationMenu`, `Breadcrumb`, `Tabs`, `Pagination`                                      |
| Overlays                   | `Dialog`, `Sheet`, `Drawer`, `AlertDialog`                                                           |
| Feedback                   | `toast` (Base), `sonner` (Radix/Aria), `Alert`, `Progress`, `Skeleton`, `Spinner`                    |
| Command palette            | `Command` inside `Dialog`                                                                            |
| Charts                     | `Chart` (wraps Recharts)                                                                             |
| Layout                     | `Card`, `Separator`, `Resizable`, `ScrollArea`, `Accordion`, `Collapsible`, `Aspect Ratio`, `Direction` |
| Empty states               | `Empty`                                                                                              |
| Menus                      | `DropdownMenu`, `ContextMenu`, `Menubar`                                                             |
| Tooltips / info            | `Tooltip`, `HoverCard`, `Popover`                                                                    |
| Chat / conversation UI     | `MessageScroller`, `Message`, `Bubble`, `Attachment`, `Marker`                                       |

## Integration With This Profile's Style

If the project uses the gov-style palette (navy `#0C2D5C`, institutional blue `#185FA5`, gold `#BA7517`) — relevant for posyandu / ANC reminder / public-health UIs — define semantic tokens in `tailwindCssFile` (typically `app/globals.css` for Next.js) instead of overriding component classes:

```css
@theme inline {
  --color-primary: var(--color-navy);
  --color-primary-foreground: var(--color-white);
  --color-ring: var(--color-navy);
  /* etc. */
}
```

Then components consume `bg-primary`, `text-primary-foreground`, `ring-ring` etc. — no raw colors anywhere in `.tsx`. Verify the resulting contrast hits WCAG AA (≥ 4.5:1 for body text) before shipping.

## Pitfalls

- **Don't re-add installed components.** Always read `npx shadcn@latest info --json` `components` array first.
- **Don't import from a registry that wasn't used.** If the user said "add a login block" without naming `@shadcn` / `@magicui` / `@tailark`, **ask** which registry. Never default.
- **Third-party registry imports.** Community registries may hardcode `@/components/ui/...` paths that don't match your project's aliases. After `npx shadcn@latest add <third-party>`, grep for `@/components/ui` in non-UI files and rewrite to match `aliases.ui` from project info.
- **Icon library mismatch.** If the registry uses `lucide-react` but the project uses `hugeicons` (or vice versa), swap imports AND icon names. Lucide's `Search` ≠ Hugeicons' `SearchIcon`. Don't leave a broken icon name in.
- **Next.js 16 RSC.** When `isRSC: true`, files using `useState`, `useEffect`, event handlers, or browser APIs need `"use client"` at the top. Reference the field, don't guess.
- **Tailwind v3 vs v4.** v3 uses `tailwind.config.js` with `theme.extend.colors`. v4 uses `@theme inline` blocks in the CSS file. Editing the wrong one silently does nothing.
- **Base vs Radix.** `Select` API differs (`render` vs `asChild`, different prop names). `ToggleGroup` and `Slider` differ too. Check `base` from project info before writing component code — don't reuse Radix snippets in a Base project or vice versa.
- **Always verify added files.** Rule 7 from the upstream SKILL.md is non-negotiable: after every `add`, read the files and look for missing sub-components, missing imports, and rule violations.
- **Updating existing components.** Use `npx shadcn@latest add <comp> --dry-run` then `--diff <file>` to preview upstream changes; never overwrite blindly. See `shadcn-ui-bootstrap` § Updating for the full merge procedure.

## Verification

- Every modified file imports from the project's alias prefix (matches `aliases.components` / `aliases.ui` from `npx shadcn@latest info`).
- Forms use `FieldGroup` + `Field`; no raw `<div className="space-y-*">` form layouts.
- All icons inside components have `data-icon` and no sizing classes.
- `Button` for loading states uses `Spinner` + `disabled`, not `isPending` / `isLoading` props.
- Overlays have a `*Title` component.
- `Avatar` has `AvatarFallback`. `Tabs` triggers are inside `TabsList`. `SelectItem` / `DropdownMenuItem` / `CommandItem` are inside their respective `*Group`.
- No raw colors in `.tsx` (`bg-blue-500`, `text-emerald-600`, etc.) — all use semantic tokens.
- No `space-x-*` / `space-y-*`. Spacing is `flex` + `gap-*`.
- Equal dimensions use `size-*`, not `w-* h-*`.
- "use client" present where required by `isRSC: true`.
- Toast import matches `base`: `toast` (Base) or `sonner` (Radix/Aria).