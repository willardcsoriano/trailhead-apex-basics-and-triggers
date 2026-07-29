# Unit 1 — Completing the Hands-On Challenge

Two phases. First, explore 10 ways to solve it. Second, submit the answer.

---

## Phase 1 — Explore All 10 Variations

### 1a. Paste the multi-variation class

**File → New → Apex Class**, name it `StringListTest`, clear the template, paste below, Ctrl+S.

```apex
/*
 * Variation 1 is ACTIVE. To test another, comment out V1
 * and remove the opening and closing comment wrappers from the next.
 */

public class StringListTest {

    // =========================================================================
    // VARIATION 1: Standard List<String> with for Loop (ACTIVE)
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }

    /*
    // =========================================================================
    // VARIATION 2: Array Notation String[] with for Loop
    // =========================================================================
    public static String[] generateStringList(Integer count) {
        String[] result = new String[] {};
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 3: Explicit String.valueOf() Conversion
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> stringList = new List<String>();
        for (Integer i = 0; i < count; i++) {
            stringList.add('Test ' + String.valueOf(i));
        }
        return stringList;
    }
    */

    /*
    // =========================================================================
    // VARIATION 4: Fixed-Size Array Index Assignment
    // =========================================================================
    public static String[] generateStringList(Integer count) {
        String[] result = new String[count];
        for (Integer i = 0; i < count; i++) {
            result[i] = 'Test ' + i;
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 5: String.format() Placeholder Template
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> output = new List<String>();
        for (Integer i = 0; i < count; i++) {
            output.add(String.format('Test {0}', new List<String>{ String.valueOf(i) }));
        }
        return output;
    }
    */

    /*
    // =========================================================================
    // VARIATION 6: while Loop
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        Integer i = 0;
        while (i < count) {
            result.add('Test ' + i);
            i++;
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 7: do-while Loop
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        Integer i = 0;
        if (count > 0) {
            do {
                result.add('Test ' + i);
                i++;
            } while (i < count);
        }
        return result;
    }
    */

    /*
    // =========================================================================
    // VARIATION 8: List Initial Capacity with Indexed Assignment
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> items = new List<String>(count);
        for (Integer i = 0; i < count; i++) {
            items[i] = 'Test ' + i;
        }
        return items;
    }
    */

    /*
    // =========================================================================
    // VARIATION 9: Inline Post-Increment (counter++)
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        List<String> strings = new List<String>();
        Integer counter = 0;
        while (counter < count) {
            strings.add('Test ' + counter++);
        }
        return strings;
    }
    */

    /*
    // =========================================================================
    // VARIATION 10: Private Helper Method Delegate
    // =========================================================================
    public static List<String> generateStringList(Integer count) {
        return buildFormattedList('Test ', count);
    }

    private static List<String> buildFormattedList(String prefix, Integer count) {
        List<String> listResult = new List<String>();
        for (Integer i = 0; i < count; i++) {
            listResult.add(prefix + i);
        }
        return listResult;
    }
    */
}
```

### 1b. Test each variation

**Debug → Open Execute Anonymous Window** (Ctrl+E), paste below.

**Check the "Open Log" checkbox** (bottom-left of the dialog), then click **Execute**.

In the log viewer that opens, check **"Debug Only"** to hide system noise. You
should see:

```
USER_DEBUG | (Test 0, Test 1, Test 2)
USER_DEBUG | All assertions passed.
```

```apex
// Call the method with 3 — it should return ['Test 0', 'Test 1', 'Test 2'].
Integer n = 3;
List<String> output = StringListTest.generateStringList(n);

// Confirm the list has exactly 3 items.
System.assertEquals(n, output.size(), 'Size mismatch');

// Confirm each item matches the expected format.
System.assertEquals('Test 0', output[0], 'Item 0 mismatch');
System.assertEquals('Test 1', output[1], 'Item 1 mismatch');
System.assertEquals('Test 2', output[2], 'Item 2 mismatch');

// Confirm that passing 0 returns an empty list (not null).
List<String> empty = StringListTest.generateStringList(0);
System.assertEquals(0, empty.size(), 'Empty size mismatch');
System.assertNotEquals(null, empty, 'Should not be null');

// If nothing threw an exception, every assertion passed.
System.debug('All assertions passed.');
```

### 1c. Cycle through variations

Only one `generateStringList` visible at a time.

| Var | Action |
|-----|--------|
| V1 | Already active. Run test. |
| V2 | Wrap V1 in `/* */`, remove `/* */` from V2, save, run test. |
| V3 | Re-wrap V2, uncomment V3, save, run test. |
| … | Repeat through V10. |

---

## Phase 2 — Submit the Trailhead Answer

After exploring, replace `StringListTest` with the clean single-variation class.

**Open `StringListTest` in the Developer Console**, Ctrl+A to select all, delete, paste below, Ctrl+S.

```apex
public class StringListTest {
    public static List<String> generateStringList(Integer count) {
        List<String> result = new List<String>();
        for (Integer i = 0; i < count; i++) {
            result.add('Test ' + i);
        }
        return result;
    }
}
```

Run the same Anonymous Apex test from Phase 1b to confirm it still works.
Then click **Check Challenge** in Trailhead.
