# Blocker Log — Unit 1

Real issues encountered while building and testing the multi-variation Apex
class with AI assistance. Each entry documents what broke, why, and how it was
fixed.

---

## 2026-07-29 — V8: `new List<String>(n)` Apex vs Java behavior

### What happened

The AI initially "fixed" Variation 8 by replacing indexed assignment
`items[i] = 'Test ' + i` with `.add()`, assuming `new List<String>(count)` only
sets initial capacity — like Java's `new ArrayList<>(n)`.

### How the test caught it

V8 failed in the test suite with size mismatches:

```
Assertion Failed: V8 → size mismatch: Expected: 4, Actual: 8
Assertion Failed: V8 → size mismatch: Expected: 1, Actual: 2
```

Two tests (`testV8_listCapacity` and `testAllVariations_singleItem`) both
reported the list was double the expected size.

### Root cause

In Apex, `new List<String>(n)` creates a list **with `n` null entries
pre-populated** — not an empty list with reserved capacity. Calling `.add()`
appended new items on top of those nulls, doubling the list size.

This is different from Java, where `new ArrayList<>(n)` creates an empty list
with only reserved capacity.

### Fix

Reverted to indexed assignment (`items[i] = 'Test ' + i;`), which overwrites
the pre-populated nulls in place. This is the correct pattern when using the
sized `List` constructor in Apex.

```apex
// Correct:
List<String> items = new List<String>(count);  // count null entries
for (Integer i = 0; i < count; i++) {
    items[i] = 'Test ' + i;  // overwrites null at position i
}

// Wrong (Apex only):
List<String> items = new List<String>(count);
for (Integer i = 0; i < count; i++) {
    items.add('Test ' + i);  // appends after nulls → doubles size
}
```

### Lesson

The AI has a Java bias in its training data and may assume Apex behaves like
Java for collection constructors. The test suite caught this before it reached
a Trailhead challenge submission. Run the tests every time the AI proposes a
code change.

---

## 2026-07-29 — `/*` and `*/` inside a block comment breaks compilation

### What happened

The class header comment contained:

```apex
/*
 * and remove the /* and */ comment wrappers from your chosen
 * variation below.
 */
```

Saving the class produced:

```
Unexpected token 'comment'. (line 6)
```

### Root cause

Apex does not support nested block comments. The second `/*` on line 5 was
interpreted as the start of a new block comment, leaving `comment` and the rest
as unparseable tokens.

### Fix

Replaced `/*` and `*/` with plain English:

```apex
 * and remove the opening and closing comment wrappers from your chosen
```

### Lesson

Never put `/*` or `*/` inside an Apex block comment — even as part of
instructional text. The AI did not catch this because it treats comments as
inert prose, but Apex compiles them literally.
